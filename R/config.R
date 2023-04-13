#' On Load
#'
#' Do this when the package loads
#'
#' ....
.onLoad <- function(libname, pkgname) {
  init_config()
  config <- read_config()
  load_config_to_env(config)
}
#' Make Config File
#'
#' Make a config file for config
#'
#' Make a json config file to saove getarc config
#' @return NULL
#' @importFrom rjson toJSON
init_config <-
  function(){
    filepath <- ".getarc-config"
    # If the file already exists do nothing
    if(file.exists(filepath)){return(NULL)}

    config <- list()

    write_config(config)

  }
#' Read the config file
#'
#' Read the config file from the standard location
#'
#' @return a list of config
read_config <-
  function(){
    filepath <- ".getarc-config"
    config <- fromJSON(paste0(readLines(filepath), collapse = ""))
    return(config)
  }
#' Edit Cofig
#'
#' Edit the config file and update the config env variables
#'
#' @param changes a 1 level named list of config to edit
#' @return NULL
edit_config <-
  function(changes){
    # read it
    config <- read_config()
    # Edit it
    config <- modifyList(config, changes)
    # Write it
    write_config(config)
    load_config_to_env(config)
  }
#' Load Config
#'
#'
#' Load the config into Env variables
#' @param config a named list of config (supplied by read_config())
#' @return NULL
load_config_to_env <-
  function(config){
    if(length(config) == 0){return(NULL)}
    # Set all config as environment variables
    do.call(Sys.setenv, config)
  }
#' Write Config
#'
#' Write the config file to standard location
#'
#' @param config a named list of config
write_config <-
  function(config){
    filepath <- ".getarc-config"
    config_json <- rjson::toJSON(x = config)
    # Writing to disk
    # Open a file connetion & write the lines of the json string
    connection <- file(filepath)
    writeLines(config_json, connection)
    # Close the file connetion
    close(connection)
  }
