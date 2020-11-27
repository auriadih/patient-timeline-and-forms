
library(xlsx)
options(xlsx.date.format="dd.MM.yyyy")
options(xlsx.datetime.format="dd.MM.yyyy HH:mm:ss")
library(data.table)
options(useFancyQuotes = FALSE)
library(RPostgreSQL)

# make sure you have the necessary PostgreSQL JDBC driver files in your PATH


# ------------------------------------------------------------------------------
#
# Source the necessary functions
#
# ------------------------------------------------------------------------------

# Set working directory to the location of the following subdirectories:
# export_form_contents/
# form_templates/
# insert_form_contents/

setwd("~/laaturekisteri/db/forms/form_creation")

# source the functions from the function definition file
source("insert_form_contents/functions_to_insert_form_definitions_from_file.R")


# ------------------------------------------------------------------------------
#
# Run parameters
#
# ------------------------------------------------------------------------------


# name of form schema
form_schema <- "wtf"
base_schema <- "base"


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


# ------------------------------------------------------------------------------
##
## Insert the user group and the form, if they don't yet exist
##
# ------------------------------------------------------------------------------

# the folder where you have your form definition
# in an Excel file
form_template_folder <- paste(getwd(), "/form_templates/",
                              sep="")

# set the group who is the owner of the form to be inserted
# (Testaaja = Tester)
owner_group_name <- "Testaaja"

# if the group is not yet in the database,
# it can be inserted like this.
# Group "Testaaja" is a root group and has no parent,
# hence the NA as second parameter value.
insert_group(owner_group_name, NA)

# ------------------------------------------------------------------------------
##
## Insert form, fields, choices and conditions.
##
# ------------------------------------------------------------------------------

#
# 1
#


# Full path to the form

form_path <- "Test forms|Test form 1"
form_number <- 1
refillable <- TRUE
header <- "This is an example for demonstrating different types of fields"
footer <- "Hope this gave you have ideas on how to define your own forms!"

form_id <- insert_form(form_path,
                       form_number,
                       refillable,
                       owner_group_name,
                       header,
                       footer)

# run this to make sure that the group Testaaja
# gets full view, insert and edit privileges to the form in the UI
allow_full_access_to_own_root_forms("Testaaja")

form_contents <- data.table(read.xlsx(file = paste(form_template_folder,
                                                   "form_content_template_and_example.xlsx", sep=""),
                                      sheetName = "Fields", header = T))
form_conditions <- data.table(read.xlsx(file = paste(form_template_folder,
                                                     "form_content_template_and_example.xlsx", sep=""),
                                        sheetName = "Conditions",
                                        header = T))

# insert into the database
insert_form_field_choices(form_id, form_contents)
if (nrow(form_conditions) > 0) {
  insert_conditions(owner_group_name, form_id, form_conditions) 
}





