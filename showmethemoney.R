# plumber.R
library(plumber)
library(yelpr)
library(dplyr)
library(twilio)
library(httr)
library(jsonlite)
library(mongolite)


lead_gen <- function (lat, long){
  yelp_key <- "mJG8TDLGqVNAiNvIDzy-3d0i6pbsZpu3oh5Rh464OFeI8Ugi_PqSVopdpTxdQUCuiR9PB4e9GJPLX1zsak3uhgGaeQ_5SugofbeV4S-U2AVXo7M9CGyEm65fWeZ-XHYx"
  twilio_sid <- "ACca237f041b5fa7b8b48f93678a6d2390"
  twilio_token <- "37c965718d8014fad7afe87d3d84aa36"
  
  cellornot <- function(number){ 
    lookup_api <- paste("https://lookups.twilio.com/v1/PhoneNumbers/",number,"?Type=carrier", sep="")
    number_info <- GET (
      lookup_api, 
      authenticate(twilio_sid, twilio_token)
    )
    parsed_response <- content(number_info, "text")
    device <- fromJSON(parsed_response)
    device$carrier$type
  }
  
  result <- business_search(api_key = yelp_key, longitude = long, latitude = lat, limit=50)
  business_leads <- result[["businesses"]]
  business_leads$device <- lapply(business_leads$phone, cellornot)
  file <- paste(lat,"-",long,".csv",sep="")
  response <- select(business_leads, name, phone, device)
  #write.csv(response, file)
  return(response)
}

## FORT WORTH CENTRAL : 32.758860, -97.328304
## NORTH POINT: 32.852772, -97.328367
## SOUTH POINT: 32.659375, -97.326164
## EAST POINT: 32.750996, -97.238101
## WEST POINT: 32.756011, -97.495700
## 1 degree is lattitude == 69 miles
## 1 mile = 1/69 = 0.014 degree
## Coordinate File: fort_worth.csv

## r <- plumb("showmethemoney.R")      // Write R File
## r$run(port=8000)                    // Launch Plumbing Server


#* Return list of 50 businesses around a coordinate
#* @param long Longtitude of the Business
#* @param lat Lattitude of the Business
#* @json
#* @get /leads
function(lat, long){
  lead_gen(lat, long)
}

