# plumber.R
library(plumber)
library(yelpr)
library(dplyr)
library(twilio)
library(httr)
library(jsonlite)
library(mongolite)

.GlobalEnv$to_export <- data.frame()

completeFun <- function(data, desiredCols) {
  completeVec <- complete.cases(data[, desiredCols])
  return(data[completeVec, ])
}

insertMongo <- function(data) {
  con <- mongo("leads", url = "mongodb+srv://troydo42:LessIsMore42!@yeaornay-q5vdv.mongodb.net/leads?retryWrites=true")
  con$insert(data)
}

lead_gen <- function (lat, long){
  
  ## API Keys
  yelp_key <- "mJG8TDLGqVNAiNvIDzy-3d0i6pbsZpu3oh5Rh464OFeI8Ugi_PqSVopdpTxdQUCuiR9PB4e9GJPLX1zsak3uhgGaeQ_5SugofbeV4S-U2AVXo7M9CGyEm65fWeZ-XHYx"
  twilio_sid <- "ACca237f041b5fa7b8b48f93678a6d2390"
  twilio_token <- "37c965718d8014fad7afe87d3d84aa36"
  
  ## Check number device type: voip, cell or landline
  cellornot <- function(number){ 
    lookup_api <- paste("https://lookups.twilio.com/v1/PhoneNumbers/",number,"?Type=carrier", sep="")
    number_info <- GET (
      lookup_api, 
      authenticate(twilio_sid, twilio_token)
    )
    parsed_response <- content(number_info, "text")
    device_info<- fromJSON(parsed_response)
    device_type = device_info$carrier$type
    if (is.null(device_type) == TRUE) {
      return("???")
    } else {
      return(device_type)
    }
  }
  
  ## Extracting business name, number by coordinates
  result <- business_search(api_key = yelp_key, longitude = long, latitude = lat, limit=50)
  business_leads <- completeFun(result[["businesses"]], "phone")
  business_leads$device <- vapply(business_leads$phone, cellornot, character(1))
  file <- paste(lat,"-",long,".csv",sep="")
  
  ## Return response to API and Write to CSV File
  .GlobalEnv$to_export <- select(business_leads, name, phone, device)
  insertMongo(.GlobalEnv$to_export)
  #assign(to_export, data, envir = .GlobalEnv)
  return(.GlobalEnv$to_export)

}


## FORT WORTH CENTRAL : 32.758860, -97.328304
## NORTH POINT: 32.852772, -97.328367
## SOUTH POINT: 32.659375, -97.326164
## EAST POINT: 32.750996, -97.238101
## WEST POINT: 32.756011, -97.495700
## 1 degree in lattitude == 69 miles
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

