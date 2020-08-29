#' Parse esri datetime
#'
#' Parse datetimes stored by esri
#'
#' @param x a vector of datetimes in the esri format
#' @return a vector of datetimes
#' @importFrom lubridate date
#' @importFrom lubridate milliseconds
parse_esri_datetime <-
  function(x){
    origin <- lubridate::date("1970-01-01")
    date <- origin + lubridate::milliseconds(as.numeric(x))
    date <- as.POSIXct(date)
    # if(is.null(tz)){
    #   return(date)
    # }else{
    # date <- lubridate::with_tz(date, tzone = tz) %>% as.POSIXct()
    return(date)
    # }
  }
