"""
Contains all mandatory database tables and (materialised) views
Add necessary columns with their formats
"""

# import login library
from flask_login import UserMixin

# import database connection handlers and login manager from local files
from main_app import DB, LOGIN_MANAGER

# schema names
BASE = 'base'
FORMIT = 'wtf'
MARTTI = 'patient_data'

# crucial tables
PATTAULU = 'person'
AIKAJANA = 'mv_timeline_element'



class User(UserMixin, DB.Model):
    """ granting access and identifying logged-in user """
    # define schema and table
    __tablename__ = 'app_user'
    __table_args__ = {'schema': BASE}

    # define column properties
    id = DB.Column("app_user_id", DB.Integer, primary_key=True)
    first_name = DB.Column(DB.String, index=True)
    last_name = DB.Column(DB.String, index=True)
    email = DB.Column(DB.String, index=True, unique=True)
    username = DB.Column(DB.String)
    password = DB.Column(DB.String)
    serial_number = DB.Column(DB.String)

    def __repr__(self):
        return '{}'.format(self.id)



@LOGIN_MANAGER.user_loader
def load_user(user_id):
    """ 'load user' / 'set user active' using login manager library """
    return User.query.get(int(user_id))



class UserGroups(DB.Model):
    """ checking which groups user does belong to """
    # define schema and table
    __tablename__ = 'v_users'
    __table_args__ = {'schema': BASE}

    # define column properties
    app_user_id = DB.Column(DB.Integer, primary_key=True)
    first_name = DB.Column(DB.String, index=True)
    last_name = DB.Column(DB.String, index=True)
    email = DB.Column(DB.String, index=True, unique=True)
    password = DB.Column(DB.String)
    valid = DB.Column(DB.Boolean)
    group_id = DB.Column(DB.Integer)
    group_name = DB.Column(DB.String)

    def __repr__(self):
        return '<User Groups: {}>'.format(self.group_name)



class PatientCheck(DB.Model):
    """ checking that patient is present in database """
    # define schema and table
    __tablename__ = PATTAULU
    __table_args__ = {'schema': BASE}

    # define column properties
    person_id = DB.Column(DB.Integer, primary_key=True)
    henkilotunnus = DB.Column(DB.String)
    lastname = DB.Column(DB.String)
    firstname = DB.Column(DB.String)
    death_date = DB.Column(DB.DateTime)
    birth_date = DB.Column(DB.DateTime)

    def __repr__(self):
        return 'Person: {}'.format(self.person_id)



class GroupFeatureAccess(DB.Model):
    """ checking that user has access to timeline """
    # define schema and table
    __tablename__ = 'group_feature_access'
    __table_args__ = {'schema': BASE}

    # define column properties
    group_id = DB.Column(DB.Integer, primary_key=True)
    feature_id = DB.Column(DB.Integer)

    def __repr__(self):
        return '<Feature: {} for Group: {}>'.format(self.feature_id, self.group_id)



class Feature(DB.Model):
    """ checking that user has access to timeline """
    # define schema and table
    __tablename__ = 'feature'
    __table_args__ = {'schema': BASE}

    # define column properties
    feature_id = DB.Column(DB.Integer, primary_key=True)
    name = DB.Column(DB.String)

    def __repr__(self):
        return '<Feature: {}>'.format(self.name)



class Session(DB.Model):
    """ keeping track of usage and accessing patient data """
    # define schema and table
    __tablename__ = 'session'
    __table_args__ = {'schema': FORMIT}

    # define columns properties
    session_id = DB.Column(DB.Integer, primary_key=True)
    app_user_id = DB.Column(DB.Integer)
    group_id = DB.Column(DB.Integer)
    person_id = DB.Column(DB.Integer)
    session_started_ts = DB.Column(DB.DateTime)
    session_ended_ts = DB.Column(DB.DateTime)
    session_end_type_id = DB.Column(DB.Integer)

    def update(self, session_ended_ts=None):
        """ update session ending timestamp """
        if session_ended_ts:
            self.session_ended_ts = session_ended_ts

    def __repr__(self):
        return '<Session: {}>'.format(self.session_id)



class AnswerSet(DB.Model):
    """ keeping track how users fill forms and which forms """
    # define schema and table
    __tablename__ = 'answer_set'
    __table_args__ = {'schema': FORMIT}

    # define columns properties
    answer_set_id = DB.Column(DB.Integer, primary_key=True, autoincrement=True)
    session_id = DB.Column(DB.Integer)
    form_id = DB.Column(DB.Integer)
    number = DB.Column(DB.Integer)
    open_ts = DB.Column(DB.DateTime)
    close_ts = DB.Column(DB.DateTime)
    save_ts = DB.Column(DB.DateTime)
    invalidated_ts = DB.Column(DB.DateTime)
    replaced_by_answer_set_id = DB.Column(DB.Integer)

    def update(self, close_ts=None):
        """ update form closing timestamp """
        if close_ts:
            self.close_ts = close_ts

    def __repr__(self):
        return '<Session: {} for Answer Set: {}>'.format(self.session_id, self.answer_set_id)



class AnswerSets(DB.Model):
    """ keeping track how users fill forms and which forms """
    # define schema and table
    __tablename__ = 'v_answer_sets'
    __table_args__ = {'schema': FORMIT}

    # define columns properties
    answer_set_id = DB.Column(DB.Integer, primary_key=True, autoincrement=True)
    session_id = DB.Column(DB.Integer)
    person_id = DB.Column(DB.Integer)
    form_id = DB.Column(DB.Integer)
    form_name = DB.Column(DB.String)
    form_lineage = DB.Column(DB.String)
    form_fullname = DB.column_property(form_lineage + " - " + form_name)
    number = DB.Column(DB.Integer)
    open_ts = DB.Column(DB.DateTime)
    close_ts = DB.Column(DB.DateTime)
    save_ts = DB.Column(DB.DateTime)
    invalidated_ts = DB.Column(DB.DateTime)
    replaced_by_answer_set_id = DB.Column(DB.Integer)
    user_group_id = DB.Column(DB.Integer)
    
    def __repr__(self):
        return '<Session: {} for Answer Set: {}>'.format(self.session_id, self.answer_set_id)



class UroJana(DB.Model):
    """ reading uromart data to construct timeline visualization """
    # define schema and table
    __tablename__ = AIKAJANA
    __table_args__ = {'schema': MARTTI}

    # define columns properties
    element_id = DB.Column(DB.Integer, primary_key=True)
    henkilotunnus = DB.Column(DB.String(50))
    person_id = DB.Column(DB.Integer)
    start = DB.Column('start_ts', DB.DateTime)
    end_ts = DB.Column('end_ts', DB.DateTime)
    className = DB.Column('category', DB.String)
    eventinfo = DB.Column('eventinfo_content', DB.String)
    tooltip = DB.Column('eventinfo_tooltip', DB.String)
    icon_text = DB.Column('icon_text', DB.String)
    group = DB.Column('significance', DB.String)

    def __repr__(self):
        return '<Timeline data for person: {}>'.format(self.person_id)



class SignificanceGroups(DB.Model):
    """ reading swimlanes dynamically """
    # define schema and table
    __tablename__ = 'significance'
    __table_args__ = {'schema': MARTTI}

    # define columns properties
    significance_id = DB.Column(DB.Integer, primary_key=True)
    significance = DB.Column(DB.String)

    def __repr__(self):
        return '<Significance Groups {}>'.format(self.significance_id)



class TimelineHelp(DB.Model):
    """ reading details about timeline elements and data """
    # define schema and table
    __tablename__ = 'help_page'
    __table_args__ = {'schema': MARTTI}

    # define columns properties
    update_ts = DB.Column(DB.DateTime, primary_key=True)
    content = DB.Column(DB.String)

    def __repr__(self):
        return '<Help Page last updated: {}>'.format(self.update_ts)



class LabCheck(DB.Model):
    """ checking which lab tests are done for patient """
    # define schema and table
    __tablename__ = 'mv_lab'
    __table_args__ = {'schema': MARTTI}

    # define columns properties
    person_id = DB.Column(DB.Integer, primary_key=True)
    test = DB.Column(DB.String)
    result = DB.Column(DB.String)
    unit = DB.Column(DB.String)
    start_ts = DB.Column(DB.DateTime)

    def __repr__(self):
        return '{}, {}, {}, {}'.format(self.test, self.result, self.unit, self.start_ts)



class EpicScores(DB.Model):
    """ fetching EPIC scores """
    # define schema and table
    __tablename__ = 'v_measurements'
    __table_args__ = {'schema':'mining'}

    # define columns properties
    person_id = DB.Column(DB.Integer, primary_key=True)
    series_group = DB.Column(DB.String)
    series_name = DB.Column(DB.String)
    value = DB.Column(DB.Integer)
    ts = DB.Column(DB.DateTime)

    def __repr__(self):
        return '{}, {}, {}, {}'.format(self.test, self.result, self.unit, self.start_ts)



class VForms(DB.Model):
    """ additional form information """
    # define schema and table
    __tablename__ = 'v_forms'
    __table_args__ = {'schema': FORMIT}

    owner_group_id = DB.Column(DB.Integer, primary_key=True)
    owner_group_name = DB.Column(DB.String)
    form_id = DB.Column(DB.Integer)
    parent_form_id = DB.Column(DB.Integer)
    form_lineage = DB.Column(DB.String)
    form_name = DB.Column(DB.String)
    is_root_form = DB.Column(DB.Boolean)
    is_leaf_form = DB.Column(DB.Boolean)
    form_header = DB.Column(DB.String)
    form_footer = DB.Column(DB.String)
    form_refillable = DB.Column(DB.Boolean)
    form_number = DB.Column(DB.Integer)

    def __repr__(self):
        return '{}'.format(self.form_id)



class FormElements(DB.Model):
    """ fetching form elements for a certain form """
    # define schema and table
    __tablename__ = 'v_form_fields'
    __table_args__ = {'schema': FORMIT}

    form_field_id = DB.Column(DB.Integer, primary_key=True)
    parent_form_id = DB.Column(DB.Integer)
    parent_form = DB.Column(DB.String)
    #child_form_id = DB.Column(DB.Integer)
    #child_form = DB.Column(DB.String)
    form_id = DB.Column(DB.Integer)
    form_name = DB.Column(DB.String)
    child_number = DB.Column(DB.Integer)
    is_leaf_form = DB.Column(DB.Boolean)
    field_id = DB.Column(DB.Integer)
    field_number = DB.Column(DB.Integer)
    field_name = DB.Column(DB.String)
    section_number = DB.Column(DB.Integer)
    is_conditional = DB.Column(DB.Boolean)
    unique_to_form = DB.Column(DB.Boolean)
    field_description = DB.Column(DB.String)
    owner_group_name = DB.Column(DB.String)
    field_type_name = DB.Column(DB.String)
    data_type_name = DB.Column(DB.String)
    field_long_name = DB.Column(DB.String)
    parent_field_name = DB.Column(DB.String)
    owner_group_id = DB.Column(DB.Integer)
    parent_field_id = DB.Column(DB.Integer)
    field_identifier = DB.Column(DB.String)
    is_root_form = DB.Column(DB.Boolean)
    field_number_nesting_order = DB.Column(DB.Integer)
    child_form_header = DB.Column(DB.String)
    child_form_footer = DB.Column(DB.String)
    is_event_ts_field = DB.Column(DB.Boolean)

    def __repr__(self):
        return '<Fetched fields for form: {}>'.format(self.child_form)



class ConditionalFields(DB.Model):
    """ fetching conditions to show or not show certain fields in certain form """
    # define schema and table
    __tablename__ = 'v_component_conditions'
    __table_args__ = {'schema': FORMIT}

    conditional_component_type = DB.Column(DB.String)
    conditional_component_id = DB.Column(DB.Integer, primary_key=True)
    conditional_form_field_id = DB.Column(DB.Integer)
    conditional_form_id = DB.Column(DB.Integer)
    conditional_form_name = DB.Column(DB.String)
    conditional_field_id = DB.Column(DB.Integer)
    conditional_field_name = DB.Column(DB.String)
    conditional_choice_id = DB.Column(DB.Integer)
    conditional_choice_name = DB.Column(DB.String)
    determining_component_type = DB.Column(DB.String)
    determining_component_id = DB.Column(DB.Integer)
    determining_form_field_id = DB.Column(DB.Integer)
    determining_form_id = DB.Column(DB.Integer)
    determining_form_name = DB.Column(DB.String)
    determining_field_id = DB.Column(DB.Integer)
    determining_field_name = DB.Column(DB.String)
    determining_choice_id = DB.Column(DB.Integer)
    determining_choice_name = DB.Column(DB.String)

    def __repr__(self):
        return '<Fetched conditional fields for form: {}>'.format(self.conditional_form_id)



class FieldChoices(DB.Model):
    """ fetching field attributes for a certain field in a certain form """
    # define schema and table
    __tablename__ = 'v_form_field_choices'
    __table_args__ = {'schema': FORMIT}

    form_field_id = DB.Column(DB.Integer, primary_key=True)
    form_id = DB.Column(DB.Integer)
    form_name = DB.Column(DB.String)
    field_id = DB.Column(DB.Integer)
    field_number = DB.Column(DB.Integer)
    field_name = DB.Column(DB.String)
    data_type_name = DB.Column(DB.String)
    field_type_name = DB.Column(DB.String)
    field_is_required = DB.Column(DB.Boolean)
    choice_number = DB.Column(DB.String)
    choice_id = DB.Column(DB.Integer)
    choice_name = DB.Column(DB.String)
    form_description = DB.Column(DB.String)
    form_field_component_id = DB.Column(DB.Integer)
    field_identifier = DB.Column(DB.String)
    field_long_name = DB.Column(DB.String)
    field_description = DB.Column(DB.String)
    form_field_choice_component_id = DB.Column(DB.Integer)
    choice_description = DB.Column(DB.String)
    choice_identifier = DB.Column(DB.String)
    choice_long_name = DB.Column(DB.String)
    gui_element_type = DB.Column(DB.String)
    gui_element_orientation = DB.Column(DB.String)

    def __repr__(self):
        return '<Fetched attributes for fields in form: {}>'.format(self.form_name)



class SaveForm(DB.Model):
    """ substituting filled form data to database """
    # define schema and table
    __tablename__ = 'answer'
    __table_args__ = {'schema': FORMIT}

    answer_id = DB.Column(DB.Integer, primary_key=True, autoincrement=True)
    answer_set_id = DB.Column(DB.Integer, primary_key=True)
    form_field_id = DB.Column(DB.Integer, primary_key=True)
    choice_id = DB.Column(DB.Integer)
    free_text = DB.Column(DB.String)

    def __repr__(self):
        return '<Saved data from Answer Set: {} to database>'.format(self.answer_set_id)



class Answers(DB.Model):
    """ fetching filled form data from database using specific view in db """
    # define schema and table
    __tablename__ = 'v_answers'
    __table_args__ = {'schema': FORMIT}

    session_id = DB.Column(DB.Integer, primary_key=True)
    person_id = DB.Column(DB.Integer)
    app_user_id = DB.Column(DB.Integer)
    henkilotunnus = DB.Column(DB.String)
    open_ts = DB.Column(DB.DateTime)
    save_ts = DB.Column(DB.DateTime)
    answer_id = DB.Column(DB.Integer, primary_key=True)
    answer_set_id = DB.Column(DB.Integer)
    free_text = DB.Column(DB.String)
    form_id = DB.Column(DB.Integer, primary_key=True)
    form_field_id = DB.Column(DB.Integer)
    form_name = DB.Column(DB.String)
    form_lineage = DB.Column(DB.String)
    form_field_component_id = DB.Column(DB.Integer)
    field_id = DB.Column(DB.Integer)
    field_number = DB.Column(DB.Integer)
    field_identifier = DB.Column(DB.String)
    field_name = DB.Column(DB.String)
    field_description = DB.Column(DB.String)
    data_type_name = DB.Column(DB.String)
    field_type_name = DB.Column(DB.String)
    field_is_required = DB.Column(DB.Boolean)
    form_field_choice_component_id = DB.Column(DB.Integer)
    field_unique_to_form = DB.Column(DB.Boolean)
    choice_id = DB.Column(DB.Integer)
    choice_name = DB.Column(DB.String)
    choice_description = DB.Column(DB.String)
    choice_number = DB.Column(DB.Integer)
    choice_identifier = DB.Column(DB.String)

    def __repr__(self):
        return '<Data from form: {} for answer: {}>'.format(self.form_id, self.answer_id)



class AllAnswers(DB.Model):
    """ fetching whole filled form from database using specific view in db """
    # define schema and table
    __tablename__ = 'v_answers_content'
    __table_args__ = {'schema': FORMIT}

    person_id = DB.Column(DB.Integer)
    session_id = DB.Column(DB.Integer, primary_key=True)
    answer_set_id = DB.Column(DB.Integer, primary_key=True)
    form_id = DB.Column(DB.Integer, primary_key=True)
    open_ts = DB.Column(DB.DateTime)
    answer_content = DB.Column(DB.String)

    def __repr__(self):
        return '<Data from form: {} at {}>'.format(self.form_id, self.open_ts)
