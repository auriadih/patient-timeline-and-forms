

####################################################################################################
#
# Script to create a database with the given name
# on the given server.
# This script should be run manually once to create an empty analytics database;
# it is not run by any of the Pentaho jobs.
# The database will be dropped if it already exists.
# The extension pg_crypto will be installed.
#
####################################################################################################


#!/bin/bash
# $1: target server name
# $2: target database name

# change this to your correct analytics directory location
cd analytics/scripts/create/db_creation

echo "Preparing $2 database on $1"

PREP_SCRIPT="temp_initialise_db_template.sql"

cat initialise_db_template.sql | perl -p -e "s/DATABASE_NAME/$2/g" > $PREP_SCRIPT

psql --file=$PREP_SCRIPT -h "$1" -U postgres -w

rm $PREP_SCRIPT




