

# Patient timeline and forms

A timeline view of patient events in health care, with dynamic forms on the side

![timeline](https://user-images.githubusercontent.com/44465250/100464018-7ab85480-30d5-11eb-8774-64b76e26a51b.PNG)

![hoitoneuvottelu_form](https://user-images.githubusercontent.com/44465250/100464132-b0f5d400-30d5-11eb-857e-184e079623cf.PNG)


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

Since the form data model is designed for data entry on customized forms, the repository includes a workflow for converting the data from this narrow input format to a wider format more suitable for data analysis. In the analytics format, each user group gets a schema where each of their forms becomes a table and each field becomes one or more columns in that table. This conversion process is programmed with Pentaho Data Integration and is found in the directory db/analytics. The main job to run to generate the analytics data format is db/analytics/main_update_analytics.kjb, for which the configuration parameters should be given in db/analytics/config/example_config.parameters.

### Authentication and authorization


The program can be configured to intergrate with Microsoft AD but it is also possible to log in with username-password. This can be set in the configuration file. AD intergration is implemented with a separate server, with which  communication happens via https-protected connection (communication protocol https, using http status codes).

Program asks for username and password, encrypts them and sends them over https over to an AD proxy server. That logs in with the credentials. If that is successful, AD proxy server sends back status code 200.


## Technologies

Ubuntu 16.04 or newer, Python, Flask framework, Gunicorn (python server), Nginx (proxy server).


### Database

The program was developed with PostgreSQL 10, so that or higher should work. After installing PostgreSQL on your server, create the database and fill it with test data using scripts in the db directory.


## Standard operations


## Adding a new form

A new form can be added by filling in the form contents in an Excel file of the format described in the examples in db\form_definition\form_templates. The form definition is inserted into the database using the R scripts in db\form_definition\insert_form_contents.
