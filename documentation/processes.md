
## General description of the software

The software is a proof-of-concept for the visualisation of electronic medical records or electronic health records (EMR/EHR) on a timeline, as well as a platform for entering supplementary patient information through a set of customisable questionnaires or forms.

The software is NOT a medical device and should NOT be used for patient care in a real-world hospital setting. The software is a prototype of the functionalities that could be useful in such a setting.

The software consists of two main components: the timeline component and the questionnaire or form component.
It is also possible to configure the software to use only one of these features without the other.


### Generic functionality

Regardless of whether the software is configured to use the timeline, forms or both, there is general functionality for user management, authentication and authorisation. Users are grouped into groups and the group determines the access rights for the user.

### Timeline

The timeline shows patient data elements visualised according to category such as diagnosis, visit, radiology, medication, etc. The answers to the forms will also be visualised as timeline elements.


### Forms

The form functionality allows users such as patients or doctors to fill in tailored questionnaires, the results of which will be visualised on the timeline.



## Technical requirements for installation and use
Linux server with Python 3.5 or newer. Tested on Ubuntu 16.04/Python 3.5 and Ubuntu 20.04/Python 3.8

### Installation instruction
#### Setup
````
git clone ggit@github.com:auriadih/patient-timeline-and-forms.git
cd patient-timeline-and-forms
virtualenv -p python3 venv
source venv/bin/activate
pip install -r requirements.txt 
````
#### Test run on local server using interactive Flask server
export FLASK_APP=run.py
flask run

### Installation on server
Software is to be run as a service. A proxy server is needed if you want to utilize CAS (VRK-card) login.
flask-patient-timeline-and-forms.service file in directory /etc/system/systemd:
````
[Unit]
Description=Gunicorn instance to serve Patient-timeline-and-forms
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=TODO-demo_Your_base_directory_/patient-timeline-and-forms
Environment="PATH=TODO-demo_Your_base_directory_/patient-timeline-and-forms/venv/bin"
ExecStart=TODO-demo_Your_base_directory_/patient-timeline-and-forms/venv/bin/gunicorn \
  --workers 3 \
  --bind unix:/tmp/flask-patient-timeline-and-forms.sock \
  --log-file TODO-demo_Your_logfile_directory_/patient-timeline-and-forms.log \
  --log-level DEBUG \
  -m 007 \
  run_gunicorn:app

[Install]
WantedBy=multi-user.target

````
### Nginx setup
In addition to your standard Nginx hardening:

````
upstream timeline {
    server unix:/tmp/flask-patient-timeline-and-forms.sock;
}


...

# Client certificate, "VRK-card, CAS" checking
# Trusted CA certificates used to verify client certificates and OCSP response
# Download and concatenate root certificates from dvv.fi
ssl_client_certificate /etc/ssl/vrk-ca-card.pem;
# Parameter optional here gives us possibility to login either with CAS card or user/password
ssl_verify_client   optional;
ssl_verify_depth     3;
ssl_session_cache  off;

# OSCP, requires nginx > 1.19
# Enable client certificate validation only
ssl_ocsp leaf;
ssl_ocsp_cache shared:oscp-cache:1m;
resolver your_dns_server_address;

#Browser ciphers may be weak, therefore prefer server ciphers
ssl_prefer_server_ciphers on;

location /timeline {
    #Client cert info
    # Certificate authentication status SUCCESS/FAILED:
    proxy_set_header X-SSL-CLIENT-VERIFY $ssl_client_verify;

    # Remaining certificate valid days
    proxy_set_header X-SSL-CLIENT-V-REMAIN $ssl_client_v_remain;

    # Certificate valid time
    proxy_set_header X-SSL-CLIENT-V-END $ssl_client_v_end;

    # Client DN. We will use serial number as id
    proxy_set_header X-SSL-CLIENT-S-DN $ssl_client_s_dn;

    proxy_set_header X-SCRIPT-NAME             /timeline;
    proxy_set_header Host                      $http_host;
    proxy_set_header X-Forwarded-For           $proxy_add_x_forwarded_for;
    proxy_set_header X-SCHEME                  $scheme;

    proxy_pass http://timeline;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

}
````

### Software

This software is tested on Python 3.5 (deprecated) on Ubuntu 16.04 and Ubuntu 20.04/Python 3.8
All needed Python packages are listed in file requirements.txt
We strongly recommend using a Python virtual environment.
All needed Python packages can then be installed using following commands:

````
# Create virtual environment
virtualenv -p python3 venv
# Activate the created environment
source venv/bin/activate
# Install packages, listed in requirements_original.txt
pip install -r requirements_original.txt
````

### Database

PostgreSQL 10 or higher

### Browsers

Firefox or Chrome recommended. Some features do not work in Internet Explorer.



### Standard operations


## Adding a new form

A new form can be added by filling in the form contents in an Excel file of the format described in the examples in db\forms\form_creation\form_templates. The form definition is inserted into the database using the R scripts in db\forms\form_creation\insert_form_contents.

### New form: consequences for analytics process

If a new form appears in the main answer collection database, the analytics database should be recreated from scratch. There is currently no process for just adding a table.


## Deleting a form

Ideally, the program should allow to 'delete' a form by just marking it as inactive in the database. However, this is not possible in the current version. The form and related fields and answers must be physically deleted from the tables to remove them from the UI. Another option is to create dummy user groups with no users and transfer ownership of the obsolete form to those groups. That way, the for will not be visible to the original owner group in the UI. In any case, it is advisable to transfer the existing answers somewhere for safekeeping before deleting the form.


## Changing an existing form

The fields on a form can be changed by directly updating the tables form_field and form_field_choice in the database. If there are no answers yet on the form, it is easier to delete the form and insert it from scratch (see section Adding a new form). If answers already exist, care must be taken not to update the wording of existing questions in a way that muddles the interpretation of the existing answers.

At the moment, there is no way to inactivate a field from being shown on a form without actually deleting the field from the form_field table. This will also mean the deletion of the existing answers.





## Known issues

The program will not work correctly with a conditional choice that depends on more than one condition.

If a choice depends on one form_field being filled, or one form_field having one specific choice selected, then it works correctly.

To correct this, the function wtf.get_choices_to_show() should return its result grouped by
(choice_id, 
choice_name, 
choice_description, 
choice_number, 
choice_identifier, 
choice_long_name) and all determining form_fields and choices should be put into a json object (see wtf.get_all_fields_to_show_aggregated() for reference). The corresponding changes must be implemented in the UI as well.