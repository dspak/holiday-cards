#!/usr/bin/env Rscript
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Title :  google-contacts_conversion.R 
# Version : 1.0
#
# Purpose : A tool that accepts google contacts exported csv and outputs those 
# contacts in a format suitable for tinyprints or shutterfly upload
#  
# Version Notes : 
#
# Created.date  : 10 Jan 2018
# Created.by    : Dan Spakowicz
# Updated.date  :  
# Updated.by    : 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Usage:      Rscript google-contacts_conversion.R -i <input file> -f <format>
### Examples:   Rscript google-contacts_conversion.R -i contacts.csv -f shutterfly
###				Rscript google-contacts_conversion.R -i contacts.csv
### Note:       	The -f flag defaults to tinyprints
###
### Input Formats:	-i 	csv exported from google in Outlook format
### Output Format:	csv with adjusted headers and names

# command line args
args <-  commandArgs(trailingOnly = TRUE)

# Load the required packages
list.of.packages <- c("optparse", "tidyverse")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if (length(new.packages)) install.packages(new.packages, 
                                          repos = "http://cran.us.r-project.org")
library(optparse)
library(tidyverse)

# set arguments
option_list = list(
  make_option(c("-i", "--input"), type = "character", default = NULL, 
              help = "google contacts export in Outlook format", metavar = "character"),
  make_option(c("-f", "--format"), type = "character", 
              default = "tinyprints", 
              help = "output format, 'shutterfly' or 'tinyprints' [default= %default]",  
              metavar = "character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# Read in data exported in "outlook" format
o <- read.csv(opt$input, row.names = NULL, as.is = TRUE, strip.white = TRUE)

# Reconfigure rows
colnames(o) <- c(colnames(o)[-1], "x")
o <- o[, colSums(is.na(o)) < nrow(o)]

# Tinyprints format
tinynames <- c("First.Name", "Last.Name", "Home.Street", "Home.Street.2", "Home.City", "Home.State", "Home.Postal.Code", "Home.Country", "E.mail.Address") 
x <- data.frame(matrix(nrow = 0, ncol = length(tinynames)))
names(x) <- tinynames

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
# Remove country bc it's all US (prob have to change this later)
out$Home.Country <- NA

# Bind back into the Tinyprints format
tp <- bind_rows(x, out)

# Convert to Shutterfly format
if (opt$format == "shutterfly") {
  colnames(tp) <- c("First Name", "Last Name", "Home Street", "Home Street 2", 
                    "Home City", "Home State", "Home Postal Code", 
                    "Home Country", "E-mail Address")
}

# Write output for uploading to website
date <- Sys.Date() %>%
  as.Date(format = "%F")
write.csv(tp, file = paste(date, "_holiday_", opt$format, ".csv", sep = ""),
            row.names = FALSE, na = "")

  

