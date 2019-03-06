# plumber.R
library(plumber)
library(yelpr)
library(twilio)

Sys.setenv(TWILIO_SID = "M9W4Ozq8BFX94w5St5hikg7UV0lPpH8e56")
Sys.setenv(TWILIO_TOKEN = "483H9lE05V0Jr362eq1814Li2N1I424t")

#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg=""){
  list(msg = paste0("The message is: '", msg, "'"))
}

#* Plot a histogram
#* @png
#* @get /plot
function(){
  rand <- rnorm(100)
  hist(rand)
}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /sum
function(a, b){
  as.numeric(a) + as.numeric(b)
}

#* Return list of 50 businesses around a coordinate
#* @param lat Lattitude of the Business
#* @param long Longtitude of the Business
#* @json
#* @get /leads
function(lat, long){
  key <- "mJG8TDLGqVNAiNvIDzy-3d0i6pbsZpu3oh5Rh464OFeI8Ugi_PqSVopdpTxdQUCuiR9PB4e9GJPLX1zsak3uhgGaeQ_5SugofbeV4S-U2AVXo7M9CGyEm65fWeZ-XHYx"
  result <- business_search(api_key = key, longitude = long, latitude = lat, limit=50)
  businesses <- result[["businesses"]]
  select(businesses, phone, name, coordinates, location)
}
