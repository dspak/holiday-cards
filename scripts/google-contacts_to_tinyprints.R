# google-contacts_to_tinyprints.R
# 
# Dan Spakowicz
# Wed Jan  3 23:55:06 2018 ------------------------------
#
#
# This script takes in a google contacts exported csv and outputs those 
# contacts in a format suitable for tinyprints upload
# 
# The processes include:
#   1) If > 1 contacts have the same address
#     1a) Reduce to 1 record
#     1b) If records last names are the same
#       1b1) Change name to The $LASTNAME Family
#       else
#       1b2) Chage name to The $LASTNAME1-$LASTNAME2 Family

library(tidyverse)

# Export contacts group "holiday card" in outlook csv format and move to the 
# same directory as this script.

# Read in data exported in "outlook" format
o <- read.csv("contacts.csv", row.names = NULL, as.is = TRUE, strip.white = TRUE)

# Reconfigure rows
colnames(o) <- c(colnames(o)[-1], "x")
o <- o[, colSums(is.na(o)) < nrow(o)]

# Tinyprints format
x <- read.csv("csv_import_template.csv", as.is = TRUE)

# Create data frame with the google contacts columns matched to tinyprints
matches <- match(colnames(x), colnames(o))
matches <- matches[!is.na(matches)]
df <- o[, matches]

# Remove rows without an address (city)
df <- df[-grep("$^", df$Home.City),]

# Create a new field for matching addresses (too many different Rd vs Rd. vs Road etc)
num.st <- strsplit(df$Home.Street, split = " ")
df$num.st <- lapply(num.st, function(x) paste(x[1], x[2], sep = " ")) %>%
  unlist

# Split out the duplicates
dups <- duplicated(df$num.st)
dupsdf <- df[dups,]
out <- df[!dups,]

# For each duplicated contact
for (i in 1:nrow(dupsdf)) {
  
  # Find the matched contact in out
  check <- grep(dupsdf$num.st[i], out$num.st)
  
  # Are the last names the same?
  all.last.names <- unique(c(out$Last.Name[check], dupsdf$Last.Name[i]))
  if (length(all.last.names) == 1) {
    # Change the name to of the last of the duplicates to $FIRSTNAME1 & 
    # FIRSTNAME2 $LASTNAME
    firstnames <- c(out$First.Name[check], dupsdf$First.Name[i])
    out$First.Name[check] <- paste(firstnames, collapse = " & ")
    out$Last.Name[check] <- all.last.names
    
  } else {
    # If multiple last names, hyphenate
    out$First.Name[check] <- paste(out$First.Name[check], out$Last.Name[check], 
                                   sep = " ")
    out$Last.Name[check] <- paste("&", dupsdf$First.Name[i], dupsdf$Last.Name[i],
                                  sep = " ")
  }
} 

# Remove the num.st col used for matching
out$num.st <- NULL
# Remove email information so tinyprints doesn't get it
out$E.mail.Address <- NA

# Bind back into the Tinyprints format
tp <- bind_rows(x, out)

# Write output for uploading to TinyPrints
date <- Sys.Date() %>%
  as.Date(format = "%F")
write.csv(tp, file = paste(date, "holiday_tinyprints.csv", sep = "_"),
          row.names = FALSE, na = "")
