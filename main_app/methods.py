""" all universal methods """

import time
import datetime
import json

from flask_wtf import FlaskForm
from wtforms import HiddenField
from sqlalchemy import func

from .models import PatientCheck, FormElements
from .models import FORMIT
from . import DB



def cur_time():
    """ function to get current time """
    return datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')



def patpat(person_id, attr):
    """ return requested patient info """
    try:
        patient_info = PatientCheck.query\
            .filter(PatientCheck.person_id == person_id)\
            .first()
        return getattr(patient_info, attr)
    except Exception:
        return None



def patage(person_id):
    """ return patient age calculated from present date """
    try:
        bday = patpat(person_id=person_id, attr='birth_date')
        dday = patpat(person_id=person_id, attr='death_date') or datetime.date.today()
        age = dday.year - bday.year
        if dday.month < bday.month or (dday.month == bday.month and dday.day < bday.day):
            age -= 1
        return age
    except Exception:
        return 0



def str_represents_int(val):
    """ check if string is really an integer """
    try:
        int(val)
        return True
    except ValueError:
        return False



def form_rights(grp_id, form_id, pat_id):
    """ check user rights to form """
    try:
        form_privs = DB.engine.execute(
            "select view_privilege, insert_privilege, modify_privilege "
            + "from " + FORMIT + ".get_privileges(" + str(grp_id) + ", " + str(form_id) + ", " + str(pat_id) + ");"
        )
        for privs in form_privs:
            dict_privs = dict(privs)
        return dict_privs
    except Exception:
        return {'insert_privilege': False, 'view_privilege': False, 'modify_privilege': False}



def form_sectioning(form_id):
    """ check how many sections form has """
    try:
        form_secs = DB.session.query(FormElements)\
            .filter(FormElements.form_id == form_id)\
            .with_entities(func.max(FormElements.section_number).label('maxi'))\
            .group_by(FormElements.form_id)\
            .scalar()
        return form_secs
    except:
        raise Exception("Failed to fetch form sectioning")



class FormTemplate(FlaskForm):
    """ empty form to be generated with other process """
    dynamically_generated = HiddenField('Dynamically generated form')

def gather_answers(fetchable, this_form_parent, this_form, row, form_nature, defaults, vastaukset_id=None):
    """ gather all answers for requested form """
    from flask import session
    from sqlalchemy import func
    from .models import Answers, FormElements

    if not fetchable:
        answers = []
        # get answers
        if form_nature == "new":
            # subquery to filter only passable fields
            # find the siblings of this form that contain this field
            sub_fields = DB.session.query(FormElements)\
                .filter((FormElements.field_id == row['field_id'])\
                    & (FormElements.parent_form_id == this_form_parent)\
                    & (FormElements.form_id != this_form))\
                .with_entities(FormElements.form_field_id)\
                .all()

            if sub_fields:
                # subquery to filter only last answer based on save_ts column in db
                sub_answers = DB.session.query(func.max(Answers.save_ts).label('maxi'))\
                    .filter((Answers.person_id == session['person_id'])\
                        & (Answers.field_unique_to_form == False)\
                        & (Answers.form_field_id.in_(sub_fields)))\
                    .group_by(Answers.person_id, Answers.field_id)\
                    .subquery()

                answers = Answers.query\
                    .filter((Answers.person_id == session['person_id'])\
                        & (Answers.field_id == row['field_id'])\
                        & (Answers.save_ts == sub_answers.c.maxi))\
                    .all()

        elif form_nature == "edit" and vastaukset_id:
            answers = Answers.query\
                .filter((Answers.answer_set_id == vastaukset_id)\
                    & (Answers.field_id == row['field_id']))\
                .all()
        else:
            raise Exception('No answer set provided')

        # gather all possible answers
        all_answers = []
        if answers:
            for answer in answers:
                if answer.field_type_name == 'vapaa_teksti':
                    if answer.free_text is not None:
                        all_answers.append(answer.free_text)
                    else:
                        pass
                else:
                    all_answers.append(str(answer.choice_id))

            # generate 'default' attribute based on count of answers
            if len(all_answers) == 1:
                if row['gui_element_type'] == 'calendar':
                    defaults += "default = datetime.datetime.strptime('" + all_answers[0] + "', '%Y-%m-%d'), "
                elif row['gui_element_type'] == 'timestamp':
                    defaults += "default = datetime.datetime.strptime('" + all_answers[0].strip() + "', '%H:%M'), "
                elif row['gui_element_type'] == 'text_field' and row['data_type_name'] == 'double':
                    defaults += "default = " + all_answers[0] + ", "
                else:
                    # for fields with only one possible answer
                    defaults += 'default = "' + all_answers[0] + '", '
            elif len(all_answers) > 1:
                # for fields with possibility of multiple answers
                defaults += "default = ['" + "', '".join(all_answers) + "'], "
        return defaults



def fetch_answers(this_form_parent, this_form, patient_answers, form_nature, row, vastaukset_id=None):
    """ gather field meta data for answered fields """
    from .models import FormElements

    # get old answers and change field default value according
    defaults = ''

    if patient_answers:
        if form_nature == "new":
            defaults = gather_answers(False, this_form_parent, this_form, row, form_nature, defaults)

        elif form_nature == "edit" and vastaukset_id:
            defaults = gather_answers(False, this_form_parent, this_form, row, form_nature, defaults, vastaukset_id)

        else:
            defaults = []
    else:
        pass

    return defaults



def generate_form(lomake_id, fill_type, vastaukset_id=None):
    """ generate dynamic forms from database attributes """
    from flask import session
    from .models import FormElements, Answers, VForms

    class Form(FormTemplate):
        """ empty form """
        pass

    from wtforms.fields.core import SelectField
    from wtforms.widgets import Select
    class AttribSelect(Select):
        """
        Renders a select field that supports options including additional html params.

        The field must provide an `iter_choices()` method which the widget will
        call on rendering; this method must yield tuples of
        `(value, label, selected, html_attribs)`.
        """
        def __call__(self, field, **kwargs):
            kwargs.setdefault('id', field.id)
            if self.multiple:
                kwargs['multiple'] = True
            html = ['<select %s>' % html_params(name=field.name, **kwargs)]
            for val, label, selected, html_attribs in field.iter_choices():
                html.append(self.render_option(val, label, selected, **dict(html_attribs)))
            html.append('</select>')
            return HTMLString(''.join(html))

    class AttribSelectField(SelectField):
        """ alter SelectField """
        widget = AttribSelect()

        def iter_choices(self):
            for value, label, render_args in self.choices:
                yield (value, label, self.coerce(value) == self.data, render_args)

    from wtforms.fields.html5 import DecimalField
    class BetterDecimalField(DecimalField):
        """
        Very similar to WTForms DecimalField, except with the option of rounding
        the data always.
        """
        def __init__(self, label=None, validators=None, places=2, rounding=None, round_always=False, **kwargs):
            super(BetterDecimalField, self).__init__(label=label, validators=validators, places=places, rounding=rounding, **kwargs)
            self.round_always = round_always

        def process_formdata(self, valuelist):
            if valuelist:
                try:
                    self.data = decimal.Decimal(valuelist[0])
                    if self.round_always and hasattr(self.data, 'quantize'):
                        exp = decimal.Decimal('.1') ** self.places
                        if self.rounding is None:
                            quantized = self.data.quantize(exp)
                        else:
                            quantized = self.data.quantize(exp, rounding=self.rounding)
                        self.data = quantized
                except (decimal.InvalidOperation, ValueError):
                    self.data = None
                    raise ValueError(self.gettext('Not a valid decimal value'))

    from wtforms import validators
    from wtforms.fields import SubmitField, StringField, SelectMultipleField, TextAreaField
    from wtforms.fields.html5 import DateField, IntegerField, DateTimeLocalField
    from wtforms_components import TimeField
    from wtforms.widgets import RadioInput, CheckboxInput, ListWidget, html_params, HTMLString

    # get parent form for this form
    this_form_parent = FormElements.query\
        .filter(FormElements.form_id == lomake_id)\
        .with_entities(FormElements.parent_form_id)\
        .first()

    # get all answers for patient
    answered = Answers.query\
        .filter(Answers.person_id == session['person_id'])\
        .all()

    # get form sectioning
    sections = form_sectioning(lomake_id)

    # get form fields from db
    res = DB.engine.execute("select "\
        + "field_id, "\
        + "form_field_id, "\
        + "field_long_name, "\
        + "array_length(field_number_nesting_order, 1) - 1 as field_number_nesting_order, "\
        + "data_type_name, "\
        + "field_type_name, "\
        + "field_is_required, "\
        + "regexp_replace(field_description, '\\n|\\t', '', 'g') as field_description, "\
        + "gui_element_type, "\
        + "gui_element_orientation, "\
        + "determining_form_fields_and_choices, "\
        + "section_number, "\
        + "show_field, "\
        + "is_event_ts_field"
        + " from " + FORMIT + ".get_all_fields_to_show_aggregated(" + str(session['person_id']) + ", " + str(session['filling_form']) + ");")
    # OBSOLETE:  vanhan get_all_fields_to_show() funktion kentät
    #        + "determining_form_field_id, "\
    #        + "determining_choice_id, "\

    if res.rowcount > 0:
        # loop through returned form fields
        for row in res:
            print(row)
            # format a new field
            generate_field = "setattr(Form, '" + str(row['form_field_id'])
            field_rendering = []

            ### determine field types

            # basic text input fields
            if row['gui_element_type'] == 'text_field':
                if row['data_type_name'] == 'char':
                    generate_field += "', StringField("
                elif row['data_type_name'] == 'int':
                    generate_field += "', IntegerField("
                elif row['data_type_name'] == 'double':
                    generate_field += "', BetterDecimalField("

            # drop-downs, radio buttons and checkboxes
            elif row['gui_element_type'] in ['select_field', 'radio_button', 'checkbox']:
                if row['gui_element_type'] in ['select_field']:
                    generate_field += "', AttribSelectField(choices = []"

                if row['gui_element_type'] in ['radio_button']:
                    generate_field += "', SelectField(choices = []"

                if row['gui_element_type'] in ['checkbox']:
                    generate_field += "', SelectMultipleField(choices = []"

                # drop-downs with choices should start with empty selection
                if row['gui_element_type'] == 'select_field':
                    generate_field += "+[('','','')]"

                    # populate other choices from db
                    for choice in DB.engine.execute("select "\
                        + "choice_id, "\
                        + "choice_name, "\
                        + "determining_form_field_id, "\
                        + "determining_choice_id"\
                        + " from " + FORMIT + ".get_choices_to_show(" + str(session['person_id']) + ", " + str(row['form_field_id']) + ")"):
                        if choice['determining_form_field_id'] is not None:
                            generate_field += "+[('" + str(choice['choice_id']) + "', '" + str(choice['choice_name']) + "',{'determining_field':'" + str(choice['determining_form_field_id'])
                            if choice['determining_choice_id'] is not None:
                                generate_field += "','determining_choice':'" + str(choice['determining_choice_id']) + "'})]"
                            else:
                                generate_field += "'})]"
                        else:
                            generate_field += "+[('" + str(choice['choice_id']) + "', '" + choice['choice_name'] + "','')]"
                    generate_field += ", "

                if row['gui_element_type'] in ['radio_button', 'checkbox']:
                    # populate other choices from db
                    for choice in DB.engine.execute("select "\
                        + "choice_id, "\
                        + "choice_name, "\
                        + "determining_form_field_id, "\
                        + "determining_choice_id"\
                        + " from " + FORMIT + ".get_choices_to_show(" + str(session['person_id']) + ", " + str(row['form_field_id']) + ")"):
                        generate_field += "+[('" + str(choice['choice_id']) + "', '" + choice['choice_name'] + "')]"
                    generate_field += ", "

                # radio buttons
                if row['gui_element_type'] == 'radio_button':
                    generate_field += "option_widget = RadioInput(), widget = ListWidget(prefix_label = False), "

                # checkboxes
                if row['gui_element_type'] == 'checkbox':
                    generate_field += "option_widget = CheckboxInput(), widget = ListWidget(prefix_label = False), "

            # date-pickers
            elif row['gui_element_type'] == 'calendar':
                generate_field += "', DateField(format = '%Y-%m-%d', "

            # times
            elif row['gui_element_type'] == 'timestamp':
                generate_field += "', TimeField(format = '%H:%M', "

            # timestamps
            elif row['gui_element_type'] == 'datetime':
                generate_field += "', DateTimeLocalField(format = '%Y-%m-%d %H:%M', "

            # bigger text fields
            elif row['gui_element_type'] == 'text_area':
                generate_field += "', TextAreaField("
                field_rendering.append("'style': 'resize: vertical; max-height: 300px; min-height: 100px;'")

            # "hidden" fields - sort of subtitles for forms
            elif row['gui_element_type'] == 'hidden':
                generate_field += "', StringField("
                field_rendering.append("'type': 'hidden'")

            # fallback for alien field type
            else:
                generate_field += "', StringField("

            # get form info from database to check if form is refillable
            form_is_refillable = DB.session.query(VForms)\
                .filter(VForms.form_id == lomake_id)\
                .with_entities(VForms.form_refillable)\
                .first()[0]

            # get old answers and change field default value according
            if vastaukset_id:
                defaults = fetch_answers(this_form_parent, lomake_id, answered, fill_type, row, vastaukset_id)
            elif not vastaukset_id and not form_is_refillable:
                defaults = fetch_answers(this_form_parent, lomake_id, answered, fill_type, row, None)
            else:
                defaults = []

            if row['gui_element_type'] == 'calendar' and not defaults:
                if row['is_event_ts_field']:
                    generate_field += 'default = datetime.datetime.today, '
                else:
                    pass
            else:
                try:
                    generate_field += defaults
                except:
                    pass

            # add orientation and indentation
            field_rendering.append("'orientation': '" + row['gui_element_orientation'] + "'")
            field_rendering.append("'indent-level': '" + str(row['field_number_nesting_order']) + "'")
            if row['field_description'] is not None:
                field_rendering.append("'tooltip': '" + str(row['field_description']) + "'")
            if row['determining_form_fields_and_choices'] is not None:
                field_rendering.append("'determining_field': '" + str(row['determining_form_fields_and_choices']) + "'")

            # OBSOLETE: vanha get_all_fields_to_show() funktion palauttama datamuoto
            #if row['determining_form_field_id'] is not None:
            #    field_rendering.append("'determining_field': '" + str(row['determining_form_field_id']) + "'")
            #if row['determining_choice_id'] is not None:
            #    field_rendering.append("'determining_choice': '" + str(row['determining_choice_id']) + "'")

            # add label and ID for field
            generate_field += "label = '" + row['field_long_name'] + "', id = " + str(row['form_field_id'])

            # add section number for field
            if sections == 1:
                field_rendering.append("'section': '" + str(sections) + "'")
            elif sections > 1:
                field_rendering.append("'section': '" + str(row['section_number']) + "'")

            # add required class for mandatory fields
            #if row['data_type_name'] in ['int', 'double'] and not row['field_is_required']:
                #generate_field += ", validators = [validators.DataRequired()]"
            if row['field_is_required']:
                generate_field += ", validators = [validators.DataRequired()]"
                # possible solution to custom error messages
                #field_rendering.append("'oninvalid':" + """'this.setCustomValidity(""" + '"This is a custom validation error!"' + ")'")

            # end field with rendering options
            generate_field += ", render_kw = { " + ", ".join(field_rendering) + " }))"

            # evaluate command string to add new field to the form
            #print("DEBUG: generate_field ------------------------------------------------------------------------------------------")
            #print(row)
            #print(generate_field)
            #print("DEBUG: ---------------------------------------------------------------------------------------------------------")

            # check if field should be shown to user
            if row['show_field'] == True or defaults:
                eval(generate_field)

        # add save button as a last field
        setattr(Form, 'Tallenna', SubmitField(label='Tallenna', id='save', render_kw={ 'section': sections }))

        form = Form()
    else:
        form = Form()
        raise Exception('No fields in {} schema on form {} for patient {}'.format(FORMIT, session['filling_form'], session['person_id']))

    return form
