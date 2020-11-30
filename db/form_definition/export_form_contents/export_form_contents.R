
## -----------------------------------------------------------------------
##
## A script that can be used to export the specified existing form definitions
## from the form schema. The definitions are exported into Excel files,
## one file per form. Each file contains two sheets, Fields and Conditions.
## The format is the same as in the templates that are used
## for inserting form defitions to the database.
##
## Author: Anna Hammais
## Date: 2020-11-30
##
## -----------------------------------------------------------------------

## -----------------------------------------------------------------------
##
## Import packages
##
## -----------------------------------------------------------------------

options(stringsAsFactors = F)
options(useFancyQuotes = FALSE)
library(xlsx)
options(xlsx.date.format="dd.MM.yyyy")
options(xlsx.datetime.format="dd.MM.yyyy HH:mm:ss")
library(RPostgreSQL)

library(data.table)


## -----------------------------------------------------------------------
##
## Set working directory
##
## -----------------------------------------------------------------------

# Set working directory to where you want to write the files

setwd("~/form_definition_exports/")


# ------------------------------------------------------------------------------
#
# Database connection
#
# ------------------------------------------------------------------------------

# postgresql driver
drv <- dbDriver("PostgreSQL")


# Retrieve the connection details from a file defined elsewhere
# that you have created (not part of the repository).
# The file should define an object called
# con_pg_target, similarly as in the else block below.
db_connection_file <- "~/laaturekisterin_huolto/db_connections/db_connection_for_insert_form_definition.R"



if(! is.null(db_connection_file)) {
  # read database connection info from file
  source(db_connection_file)
} else {
  # define your database connection object like this
  con_pg_target <- dbConnect(drv,
                             dbname="my_db",
                             user = "me",
                             host="my_server",
                             port=5432,
                             password = readLines(pwd_file))
}

# check that you have the correct target
target_server
target_db


dbSendQuery(con_pg_target,"SET client_encoding = 'utf8'")



## -----------------------------------------------------------------------
## Retrieve form definitions from a dedicated view in the database
## -----------------------------------------------------------------------


fields_query <- "select * from wtf.v_form_field_definitions_for_export"
conditions_query <- "select * from wtf.v_condition_definitions_for_export"

fields <- data.table(dbGetQuery(con_pg_target,
                                fields_query))

conditions <- data.table(dbGetQuery(con_pg_target,
                                conditions_query))


# Get a list of the forms to be exported.
# This should be configured according to needs.
forms <- data.table(dbGetQuery(con_pg_target,
                               "select form_id, form_name
                               from wtf.v_forms 
                               where form_lineage = 'Test forms'"))



## -----------------------------------------------------------------------
# Write each form into a separate Excel file
## -----------------------------------------------------------------------


# loop over forms
for (i in forms$form_id) {
  
  file_name <- paste0(Sys.Date(),"_",
                      "form_definitions_",
                      forms[form_id == i]$form_name,
                      ".xlsx")
  
  data_to_write<- NULL
  data_to_write$Fields <- fields[form_id == i, !"form_id"]
  data_to_write$Conditions <- conditions[conditional_form_id == i, !"conditional_form_id"]
  
  # write Fields and Conditions on separate sheets in the file
  write.xlsx(data_to_write$Fields, file_name, sheetName="Fields", 
             col.names=TRUE, row.names=FALSE, append=FALSE)
  write.xlsx(data_to_write$Conditions, file_name, sheetName="Conditions", 
             col.names=TRUE, row.names=FALSE,append = TRUE)
  
}

