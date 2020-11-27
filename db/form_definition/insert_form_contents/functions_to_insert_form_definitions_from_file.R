

# ------------------------------------------------------------------------------
##
## This file contains the functions needed to insert form definitions
## into the form schema (most likely read from an Excel file using
## insert_form_contents_from_file.R script).
##
## Author: Anna Hammais, Auria Clinical Informatics
## Date: 2020-11-27
##
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
##
## Function definitions
##
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# 
# Inserts the definitions of an entire form into the database.
# Parameter form_id specifies which form to attach these definitions to.
# Hence, the form itself must
# be inserted prior to calling this function.
# Parameter form_data is expected to contain the fields
# and their corresponding answer choices in a very specific format.
# This is equivalent to the Fields sheet in form_content_template.xlsx,
# which is included in the release.
#
# If the form_fields or form_field_choices read from form_data already exist
# in the form schema, the function does nothing.
# The function has no return value.
#
#-------------------------------------------------------------------------------

insert_form_field_choices <- function(form_id, form_data) {
  
  # throws error if given data is empty
  if (nrow(form_data) == 0) {
    stop("Empty data was given.")
  }
  
  
  # data quality check first
  proceed <- check_conflicting_values(form_data)
  
  
  # if data quality check was successful
  if (proceed$success) {
    
    analytics_context_id <- dbGetQuery(con_pg_target,
                                       "select context_id
                                       from wtf.context
                                       where context_name = 'analytics'")
    
    
    # go over data rows
    for (i in 1:nrow(form_data)) {
      
      #
      # read values from the row and assign them into varibles
      #
      
      section_number <- form_data[i]$Form_subsection_number
      
      if (is.null(section_number) || is.na(section_number) || length(section_number) == 0) {
        section_number <- 1
      }
      
      field_name <- form_data[i]$Field_name
      field_number_path <- form_data[i]$Field_number_with_pipe_separator
      field_help <- form_data[i]$Field_help_text
      field_type <- form_data[i]$Field_type
      
      # blank should be interpreted as FALSE
      is_main_ts <-form_data[i]$Field_denotes_primary_event_time
      is_main_ts <- ifelse(is.null(is_main_ts) || is.na(is_main_ts) ||
                             is_main_ts == "",
                           "FALSE",
                           is_main_ts)
      
      
      field_identifier <- form_data[i]$Field_identifier
      data_type <- form_data[i]$Data_type
      
      # blank should be interpreted as FALSE
      field_is_required <- form_data[i]$Field_is_obligatory
      field_is_required <- 
        sQuote(ifelse(is.null(field_is_required) || is.na(field_is_required) ||
                        field_is_required == "",
                      "FALSE",
                      field_is_required))
      
      
      # blank should be interpreted as FALSE
      not_unique_to_form <- form_data[i]$Field_data_transferrable_to_other_form
      not_unique_to_form <- 
        ifelse(is.null(not_unique_to_form) || is.na(not_unique_to_form) ||
                        not_unique_to_form == "",
                      "FALSE",
                      not_unique_to_form)
      
      analytics_synonym <- form_data[i]$Field_short_name_for_analytics
      
      gui_element_type <- form_data[i]$GUI_component
      gui_element_orientation <- form_data[i]$GUI_component_orientation
      
      
      choice_name <- form_data[i]$Choice_name
      choice_number <- form_data[i]$Choice_number
      choice_help <- form_data[i]$Choice_help_text
      choice_identifier <- form_data[i]$Choice_identifier
      choice_points <- form_data[i]$Choice_points
      
      
      # get the full path of the field instead of just the name or number path
      field_path <- get_field_path(form_data, field_number_path)
      
      
      # if gui_element_orientation is not null, concatenate it after gui_element_type
      
      gui_element_type_name_and_orientation <- 
        ifelse (is.null(gui_element_orientation) || is.na(gui_element_orientation),
                gui_element_type,
                paste(gui_element_type, "|",
                      gui_element_orientation,
                      sep=""))
      
      
      # negate not_unique_to_form to create unique_to_form, which can be inserted
      unique_to_form <- sQuote(paste("NOT ", not_unique_to_form, sep=""))
      
      
      # compose the query to insert the field
      query <-
        paste("select ", form_schema, ".insert_field(",
              form_id, ", ",
              sQuote(field_path), ", ",
              sQuote(field_number_path), ", ",
              handle_nulls(field_type, quote=TRUE), ", ",
              sQuote(gui_element_type_name_and_orientation), ", ",
              handle_nulls(data_type, quote=TRUE), ", ",
              "func.cast_to_boolean(", field_is_required, "), ",
              handle_nulls(field_help, quote=TRUE), ", ",
              handle_nulls(field_identifier, quote=TRUE), ", ",
              "func.cast_to_boolean(", handle_nulls(unique_to_form, quote=FALSE), 
              "),",
              sQuote(is_main_ts), ", ",
              section_number,
              ")", sep="")
      
      
      # print for debugging
      # print(query)
      
      
      # insert the field and retrieve its id
      form_field_id <-
        dbGetQuery(con_pg_target, query)
      
      component_id <-  get_component_id(form_field_id = form_field_id)
      
      # insert form_field analytics synonym, if given
      if (!is.null(analytics_synonym) && !is.na(analytics_synonym)) {
        analytics_synonym_query <- paste("insert into wtf.synonym",
                                         " (context_id, synonym_name, referred_table, referred_id)",
                                         "values (",
                                         analytics_context_id,
                                         ", ", sQuote(analytics_synonym),
                                         ", 'component', ",
                                         component_id, ")",
                                         " on conflict (context_id, referred_table, referred_id) do update",
                                         " set synonym_name = excluded.synonym_name",
                                         sep = "")
        dbExecute(con_pg_target, analytics_synonym_query)
      }
      
      
      
      # if choice is given, insert it into form_field_choice
      
      if ( !is.null(choice_number) && !is.na(choice_number) ) {
        query <- paste("select ", form_schema, ".insert_choice(",
                       form_field_id, ",",
                       sQuote(choice_name), ", ",
                       choice_number, ", ",
                       handle_nulls(choice_help, quote=TRUE), ", ",
                       handle_nulls(choice_identifier, quote=TRUE), ", ",
                       handle_nulls(choice_points, quote=FALSE), ")",
                       sep="")
        
        
        # print for debugging if necessary
        # print(query)
        
        oldw <-getOption("warn")
        options(warn = -1)
        
        dbExecute(con_pg_target, query)
        
        options(warn = oldw)
        
      }
    }
  }
  else {
    stop(proceed$error_message)
  }
  
}


# ------------------------------------------------------------------------------
# This function does a quality check on the given data.
# It checks combinations of values that may not be allowed on the same row.
# For example, if given data type is "timestamp",
# then the matching GUI element type must also be "timestamp".
# If given data type is "date", the matching GUI element type is "calendar".
# This is what the GUI expects and will not work correctly otherwise.
#
# Returns a list of two elements:
#
# First element: a boolean, TRUE when everything is in order, and FALSE otherwise.
# Second element: A string containing an informative error message.
# Only the first observed error is returned.
#
# ------------------------------------------------------------------------------

check_conflicting_values <- function(form_data) {
  
  # this list will contain the two elements to be returned
  result <- list()
  
  # go over all rows in data
  for (i in 1:nrow(form_data)) {
    
    
    # read relevant fields into variables
    field_number_path <-
      form_data[i]$Field_number_with_pipe_separator
    
    field_type <- 
      form_data[i]$Field_type
    
    data_type <-
      form_data[i]$Data_type
    
    gui_element_type <-
      form_data[i]$GUI_component
    
    
    # field number path can contain only max two numbers,
    # possibly separated by a pipe symbol (see error message below)
    if (! grepl("^\\d+\\|?\\d*$", field_number_path)) {
      result$success <- FALSE
      result$error_message <-
        paste("Field_number_with_pipe_separator can be one of the following formats: 3 or 3|1. ",
              "You entered the value between the brackets: [", field_number_path, "]", sep="")
      return(result)
    }
    
    
    # non-answerable fields are not allowed to have a data_type
    if (field_type == "ei_vastausta" & !is.na(data_type) && data_type != '' ) {
      
      result$success <- FALSE
      
      result$error_message <-
        "If field_type is ei_vastausta, data_type must be left blank."
      
      return(result)
    }
    
    
    
    # certain data_types require certain gui_element_types:
    # date requires calendar
    if (!is.na(data_type)
        && data_type == "date"
        & gui_element_type != "calendar") {
      
      result$success <- FALSE
      
      result$error_message <-
        "If data_type is date, gui_element_type must be calendar."
      
      return(result)
    }
    
    
    # certain data_types require certain gui_element_types:
    # time requires timestamp
    if (!is.na(data_type) &&
        data_type == "time" &
        gui_element_type != "timestamp") {
      
      result$success <- FALSE
      
      result$error_message <-
        "If data_type is time, gui_element_type must be timestamp"
      
      return(result)
    }
    
    # certain data_types require certain gui_element_types:
    # datetime requires datetime
    if (!is.na(data_type) &&
        data_type == "datetime" &
        gui_element_type != "datetime") {
      
      result$success <- FALSE
      
      result$error_message <-
        "If data_type is datetime, gui_element_type must be datetime"
      
      return(result)
    }
    
  }
  
  
  # if no problem was observed, return true with an NA error message
  result$success <- TRUE
  result$error_message <- NA
  return(result)
  
}



# ------------------------------------------------------------------------------
# 
# Inserts the definitions of the conitionalities related to a specific form
# into the database.
# The form itself and its fields and choices must first be inserted using the
# insert_form_field_choices(form_id, form_data) function.
#

# Parameter condition_data is expected to contain
# the conditional and determining fields in a very specific format.
# This is equivalent to the Conditions sheet in form_content_template.xlsx,
# which is included in the release.
#
# If the given conditions already exist in the database, does nothing.
# The function has no return value.
#
# Parameter owner_group_name, together with
# condition_data$Determining_form_path_with_pipe_separator
# determine the identity of the determining form on each row,
# i.e. the form on which the determining fields appear.
# Parameter form_id determines the identity of the conditional for,
# i.e. the form on which  the conditional fields appear.
#
# If the given component_conditions don't exist, inserts them.
# Returns nothing.
# ------------------------------------------------------------------------------

insert_conditions <- function(owner_group_name, form_id, condition_data) {
  
  # throws error if given data is empty
  if (nrow(condition_data) == 0) {
    stop("Empty data was given.")
  }
  
  # for each condition row read
  for (i in 1:nrow(condition_data)) {
    
    # read values from the row and set the into varibles
    
    conditional_field_name <-
      condition_data[i]$Conditional_field_name
    
    conditional_field_number_path <-
      condition_data[i]$Conditional_field_number_with_pipe_separator
    
    conditional_choice_name <-
      condition_data[i]$Conditional_choice_name
    
    determining_form_path <-
      condition_data[i]$Determining_form_path_with_pipe_separator
    
    determining_field_name <-
      condition_data[i]$Determining_field_name
    
    determining_field_number_path <-
      condition_data[i]$Determining_field_number_with_pipe_separator
    
    determining_choice_name <-
      condition_data[i]$Determining_choice_name
    
    negated <-
      condition_data[i]$Condition_negated
    
    if(!is.na(conditional_field_name)) {
      ##
      ## Get the component_id of the conditional component
      ##
      
      
      conditional_form_field_id <-
        get_form_field_id(form_id,
                          conditional_field_number_path)
      
      
      conditional_component_id <-
        get_component_id(conditional_form_field_id,
                         conditional_choice_name)
      
      ##
      ## Get the component_id of the determining component
      ##
      
      query <- paste("select ", form_schema, ".get_form_id(",
                     sQuote(determining_form_path), ", ",
                     sQuote(owner_group_name), ")",
                     sep="")
      
      
      determining_form_id <- dbGetQuery(con_pg_target, query)

      
      
      determining_form_field_id <-
        get_form_field_id(determining_form_id,
                          determining_field_number_path)
      
      
      determining_component_id <-
        get_component_id(determining_form_field_id,
                         determining_choice_name)
      
      
      
      #
      # Insert the condition
      #
      insert_component_condition(conditional_component_id,
                                 determining_component_id,
                                 negated)
    }
    
  }
  
  
}



# ------------------------------------------------------------------------------
# Returns a string suitable to concatenate into an SQL statement.
# NULL or NA --> "NULL"
# Any other value is quoted if quote=TRUE, otherwise returned as is.
# ------------------------------------------------------------------------------
handle_nulls <- function(input, quote) {
  
  if (! is.null(input) && !is.na(input) && length(input) != 0) {
    
    if (quote) {
      result <- sQuote(input)
    }
    else {
      result <- input
    }
    
  }
  
  else {
    result <- "NULL"
  }
  
  return (result)
  
}



# ------------------------------------------------------------------------------
# Utility function.
# Returns TRUE if the input can be interpreted as a value denoting TRUE,
# else returns FALSE.
# ------------------------------------------------------------------------------
handle_boolean <-function(input) {
  
  if (! is.null(input) && !is.na(input) &&
      str_trim(toupper(input)) %in% c("KYLLÄ","KYLLA","YES", "Y",
                                "TRUE","T", "1","X", "NOT 0", "NOT FALSE") ) {
    return (TRUE)
  }
  else {
    return (FALSE)
  }
}


# ------------------------------------------------------------------------------
# Utility function.
# Given a field number path,
# extract the equivalent field name path from the form_data.
# Returns a string that represents the field
# and all its parent fields concatenated into
# one string, separated by a pipe (|).
# ------------------------------------------------------------------------------
get_field_path <- function(form_data, field_number_path) {
  
  # extracts the field_name of the field specified in field_number_path
  result <-
    unique(form_data[as.character(Field_number_with_pipe_separator) ==
                       as.character(field_number_path)]$Field_name)
  
  
  
  # splits the given field_number_path into its constituent parts
  # that are separated by "|"
  numbers <- strsplit(x = as.character(field_number_path),
                      split = "|",
                      fixed=TRUE)[[1]]
  
  # if the path contains more than one part,
  # recursively calls this function for the second-to-last part
  # and prepends the parent field's name to the child field's name
  if (length(numbers) > 1) {
    
    result <-
      paste(get_field_path(form_data,
                           numbers[1:length(numbers)-1]),
            result,
            sep="|")
  }
  return (result)
  
}


# ------------------------------------------------------------------------------
# Returns the form_field_id of the given field in the given form.
# 
# ------------------------------------------------------------------------------
get_form_field_id <- function(form_id,  field_number_path) {
  
  query <- paste("select ", form_schema, ".get_form_field_id(",
                 form_id, ", ",
                 sQuote(field_number_path), ")",
                 sep="")
  
  
  return (dbGetQuery(con_pg_target, query))
  
}


# ------------------------------------------------------------------------------
# Returns the component_id of the given form_field + choice combination.
# The component can be a form_field (if choice_name is null)
# or a form_field_choice (if choice_name is not null).
# ------------------------------------------------------------------------------
get_component_id <- function(form_field_id,  choice_name = NULL) {
  
  # if choice_name was given, retrieve its id from database
  if (!is.null(choice_name) && !is.na(choice_name)) {
    
    # form query to retrieve choice_id from database
    query <- paste("select ", form_schema, ".get_choice_id(",
                   form_field_id, ", ",
                   sQuote(choice_name), ")",
                   sep="")
    
    choice_id <- dbGetQuery(con_pg_target, query)
    
  }
  
  else {
    choice_id <- NULL
  }
  
  # form query to retrieve component_id from database
  query <- paste("select ", form_schema, ".get_component_id(",
                 form_field_id, ", ",
                 handle_nulls(choice_id, quote=FALSE), ")",
                 sep="")
  
  return (dbGetQuery(con_pg_target, query))
  
}

# ------------------------------------------------------------------------------
# If the given user_group doesn't exist in the database, inserts it.
# Returns nothing.
# This function directly calls the equivalent pg function.
# ------------------------------------------------------------------------------
insert_group <- function(group_name,
                         parent_group_name) {
  
  # insert by pg function
  query <- paste("select ", base_schema, ".insert_group('",
                 group_name, "',",
                 handle_nulls(parent_group_name,
                              quote = TRUE), ")", sep="")
  
  # suppress warnings
  oldw <- getOption("warn")
  options(warn = -1)
  
  dbExecute(con_pg_target, query)
  
  
  options(warn = oldw)
}


# ------------------------------------------------------------------------------
# If the given component_condition doesn't exist, inserts it.
# Returns nothing.
# # This function directly calls the equivalent pg function.
# ------------------------------------------------------------------------------
insert_component_condition <- function(conditional_component_id,
                                       determining_component_id,
                                       negated) {
  
  # converts the given boolean input to TRUE or FALSE
  # (can handle e.g. 1 and 0)
  negation <- handle_boolean(negated)
  
  
  # query for inserting the condition
  query <- paste("insert into ",
                 form_schema, ".component_condition ",
                 "(conditional_component_id,",
                 "determining_component_id,",
                 "negation) values (",
                 conditional_component_id, ", ",
                 determining_component_id, ", ",
                 negation,
                 ") on conflict (conditional_component_id,
                 determining_component_id) do nothing",
                 sep="")
  
  
  # suppress warnings
  oldw <- getOption("warn")
  options(warn = -1)
  
  
  dbExecute(con_pg_target, query)
  
  
  options(warn = oldw)
  
}

# ------------------------------------------------------------------------------
# If the given form doesn't exist, inserts it.
# Returns the form_id.
# # This function directly calls the equivalent pg function.
# ------------------------------------------------------------------------------
insert_form <- function(form_path,
                        form_number,
                        refillable,
                        owner_group_name,
                        header_text,
                        footer_text) {
  
  
  # query for inserting the form
  query <- paste("select ", form_schema, ".insert_form(",
                 sQuote(form_path), ",",
                 form_number, ", ",
                 refillable, ", ",
                 sQuote(owner_group_name), ", ",
                 handle_nulls(header_text, quote = TRUE), ", ",
                 handle_nulls(footer_text, quote = TRUE), ")",
                 sep="")
  
  
  # insert form and return the inserted form's id
  form_id <- as.integer(dbGetQuery(con_pg_target, query)[1,1])
  
  
  return (form_id)
}


# ------------------------------------------------------------------------------
# Give the group full access to its own root forms.
# This is routinely done whenever a new form is inserted.
# This function directly calls the equivalent pg function.
# ------------------------------------------------------------------------------
allow_full_access_to_own_root_forms <- function(group_name) {
  
  # query for calling the pg function
  query <- paste("select ", form_schema, ".allow_access_to_own_root_forms(",
                 "group_id, true, true, true) ",
                 "from ", base_schema, ".user_group where group_name = ",
                 sQuote(group_name),
                 sep="")
  
  
  # suppress warnings
  oldw <- getOption("warn")
  options(warn = -1)
  
  dbExecute(con_pg_target, query)
  
  options(warn = oldw)
}

