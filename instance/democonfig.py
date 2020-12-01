"""
Setup Secret key
Setup Database connection
Other possible SQLAlchemy settings
TODO-demo
Read in parameter for SQLAlchemy connection string
"""

import os.path

# unique secret key (used for hashing password etc.)
SECRET_KEY = 'Create_your_own_secret_code, please.'

USR = ''
PW_DB = ''
PG_URL = ''
PG_DB = ''

# postgres database settings
SQLALCHEMY_DATABASE_URI = 'postgresql://' + USR + ':' + PW_DB + '@' + PGURL + '/' + PG_DB
SQLALCHEMY_TRACK_MODIFICATIONS = 'False'

# Other settings
REPORT_PATH = '/rpt-services/reports.html'
