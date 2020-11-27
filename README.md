# patient-timeline-and-forms
A timeline view of patient events in health care, with dynamic forms on the side


## Features


## Installation

### Database

The program was developed with PostgreSQL 10, so that or higher should work. After installing PostgreSQL on your server, create the database and fill it with test data using scripts in the db directory.


# Repository still missing some bits

Full code base for the installable software will be available by the end of 2020.


## Standard operations


## Adding a new form

A new form can be added by filling in the form contents in an Excel file of the format described in the examples in db\form_definition\form_templates. The form definition is inserted into the database using the R scripts in db\form_definition\insert_form_contents.
