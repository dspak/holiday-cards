# holiday-cards

##  Background
Each year my family sends out about a hundred holiday cards to family and friends. We've taken to using a service like Shutterfly or tinyprints that can mail the cards on your behalf provided a set of properly formatted addresses. We find this to be a huge time saver (in theory).

## The problem with Shutterfly's address book
These holiday card services each require that the addresses are uploaded in slightly different formats, and because they want to lock you into their service, they often don't allow you to export again. Therefore any slight adjustments you made to your addresses within that service serve as barriers to using other services, lest you have to update your addresses again. However, we're cheap enough, and the products from each service are similar enough, that we are more than willing to change services given a big enough coupon. I therefore wanted a way to be able to quickly create the properly formatted address labels for several different services. 

## Less automated solutions
For a few years we tried to keep a master excel spreadsheet with all of our holiday card addresses, such that we could quickly reformat as needed by changing column names or ordering. However, it proved pretty annoying to update. Many of our friends are still moving around so around 30% of the rows in our spreadsheet had to be updated each year -- and I find updating spreadsheets pretty annoying. We'd have to manually transcribe changes made on our phones to apple or google contact cards, we were forever checking several sources to figure out which address was current, and many times we'd be trying to drive somewhere and would have to check that master spreadsheet to get an address for directions. I probably have a lower tolerance for stuff like that than I should.

I wanted a system that could be easily updated from phones, had modern features like "find and merge contacts" to avoid redundancy, and could easily be synchronized between my wife's and my phones and computers. I decided on using google contacts because I use google a lot anyway, and it has the added benefit of being able to search for names in the google maps app to get directions.

## Function of this repo
Each person to whom a holiday card should be addressed was given a google contact card with the same address and a tag (I used "holiday card"). Google contacts can export groups based on the tag. The final step, and the purpose of these scripts, is to take a set of contacts and properly format the names of the addressees. 

For example, I might have a google contact for Jane Doe and John Doe, who live at the same address. The script finds the same addresses and, if their last names are the same, changes the addressee line to Jane & John Doe (with alphabetical ordering), and removes one of the two address rows. If Jane kept her maiden name, Buck, then the addressee name is changed to Jane Buck & John Doe. 

The input is a google contact exported csv __in Outlook format__, and the output is a csv with the names changed as above and redundant rows removed in the format needed for uploading. Right now the script works for Shutterfly. 
