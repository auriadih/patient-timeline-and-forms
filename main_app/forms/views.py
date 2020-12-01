""" forms module routes and logics """

# redirecting and rendering functionality from Flask library
from flask import redirect, render_template, url_for

# data handling functions from Flask library
from flask import request, jsonify, session
from flask_restful import fields, marshal

# import login functions
from flask_login import login_required

# import form functions
from . import forms_module

# import useful methods
from ..methods import cur_time, patpat, patage, form_rights, generate_form, FormTemplate

# import database connection settings
from .. import DB
from ..models import SaveForm, Answers, AllAnswers, AnswerSet, AnswerSets, VForms, FieldChoices



@forms_module.route('/lomake/<lomake_id>', methods=['GET'])
@login_required

def dynamic_form(lomake_id):
    """ generate dynamic form """

    # fallback for accessing the form with url manually
    form_privs = form_rights(session['user_group_id'], lomake_id, session['person_id'])
    if form_privs['insert_privilege'] is False:
        # redirect to homepage if user has no rights to see this form
        return redirect(url_for('main.homepage'))

    else:
        session['filling_form'] = lomake_id
        session['filling_time'] = cur_time()

        # save session to db
        ses = AnswerSet(session_id=session['session_id'], number=1, form_id=session['filling_form'], open_ts=session['filling_time'])
        DB.session.add(ses)
        DB.session.flush()
        session['answer_set_id'] = ses.answer_set_id
        DB.session.commit()

        try:
            form = generate_form(lomake_id, "new")
            fallback = False
        except:
            form = FormTemplate()
            fallback = True
            raise Exception("No fields on form")

        # get form info
        form_info = DB.session.query(VForms)\
            .filter(VForms.form_id == lomake_id)\
            .first()

        # empty form fallback
        if fallback:
            redir = '../'

        elif session['sees_timeline']:
            redir = '../aikajana'
        else:
            redir = '../'

        if session['sees_confirmation']:
            success = '../success'
        else:
            success = redir

        # render generic html body using jinja2 template (to be substituted to any page, not an independent form page)
        return render_template('forms/formi.html',
            form=form,
            patient=patpat(person_id=session['person_id'], attr='henkilotunnus'),
            suku=patpat(person_id=session['person_id'], attr='lastname'),
            etu=patpat(person_id=session['person_id'], attr='firstname'),
            kuollut=patpat(person_id=session['person_id'], attr='death_date'),
            ika=patage(person_id=session['person_id']),
            default_page=redir,
            success_page=success,
            name=form_info.__dict__['form_name'],
            header=form_info.__dict__['form_header'] or '',
            footer=form_info.__dict__['form_footer'] or '',
            user_group=session['user_group_id'],
            answer_set=ses.answer_set_id
        )



# save data from filled form to database maintaining session and user info
@forms_module.route('/save', methods=['POST'])
@login_required

def formdata_to_database():
    """ save filled form information to database """

    # get form data
    form_data = request.form
    substituted_form = form_data['dynamically_generated']

    # get path
    url_root = request.url_root.rsplit('/')
    origin_url = request.referrer.rsplit('/', 3)[1:]
    origin_path = [item for item in origin_url if item not in url_root]
    
    subpage = origin_path[0] or ''
    form_id = origin_path[1] or ''
    try:
        answer_set_id = origin_path[2]
    except IndexError:
        answer_set_id = ''

    privileges = form_rights(session['user_group_id'], form_id, session['person_id'])

    current_answer_set = form_data['answer_set']

    for field in form_data.keys():
        if field not in ['csrf_token', 'dynamically_generated', 'answer_set']:
            # get field metadata
            fields_meta = FieldChoices.query\
                .filter((FieldChoices.form_id == substituted_form) & (FieldChoices.form_field_id == field))\
                .with_entities(FieldChoices.form_id, FieldChoices.form_field_id, FieldChoices.field_type_name)\
                .first()

            for answer in form_data.getlist(field):
                # answer is empty and form is already validated,
                # it is optional field which is left blank
                if (subpage == 'lomake' and privileges['insert_privilege']) or (subpage == 'edit' and privileges['modify_privilege']):
                    if answer != '':
                        # save data from different field types
                        if fields_meta[2] == 'vapaa_teksti':
                            to_db = SaveForm(answer_set_id=current_answer_set, form_field_id=fields_meta[1], free_text=answer)
                        else:
                            to_db = SaveForm(answer_set_id=current_answer_set, form_field_id=fields_meta[1], choice_id=answer)
                        DB.session.add(to_db)
                        #DB.session.flush()

                        # end form session by filling save timestamp
                        DB.session.query(AnswerSet)\
                            .filter(AnswerSet.answer_set_id == to_db.answer_set_id)\
                            .update({AnswerSet.save_ts: cur_time()})
                else:
                    return('Tätä lomaketta ei voida enää täyttää tälle potilaalle. Halutessasi muokkaa jo tallennettua lomaketta.', 429)

        elif field in ['answer_set'] and subpage == 'edit':
            # end form session by filling save timestamp
            DB.session.query(AnswerSet)\
                .filter(AnswerSet.answer_set_id == answer_set_id)\
                .update({AnswerSet.invalidated_ts: cur_time(), AnswerSet.replaced_by_answer_set_id: current_answer_set})
    DB.session.commit()

    # flush session
    session['filling_form'] = None
    session['answer_set_id'] = None

    return('Successfully saved!', 200)



@forms_module.route('/success', methods=['GET'])
@login_required

def successfully_something():
    """ alternate redirection links """
    if session['sees_timeline']:
        redir = './aikajana'
    else:
        redir = './'

    return render_template('forms/confirmation.html', default_page=redir, demographics_access=False, user_group=session['user_group_id'])



@forms_module.route('/_checkanswers', methods=['GET'])
@login_required

def answered_forms():
    """ checking answered forms """
    # TODO: add here additional check that btn-success class is only assigned to button if the answer for that form is today
    # TODO: change this to form_filled() postgres function
    db_answered_forms = Answers.query\
        .filter(Answers.person_id == session['person_id'])\
        .distinct(Answers.form_id)\
        .order_by(Answers.form_id)\
        .all()

    form_details = {
        'form_id': fields.Integer,
        'form_name': fields.String
    }

    # if something is returned, then marshal object for the front-end
    jsonresp = jsonify(forms=marshal(db_answered_forms, form_details))
    return jsonresp



@forms_module.route('/listaus/<lomake_id>', methods=['GET'])
@login_required

def listing(lomake_id):
    """ list all answers for chosen form """

    # fallback for accessing the form with url manually
    form_privs = form_rights(session['user_group_id'], lomake_id, session['person_id'])
    if form_privs['view_privilege'] is False:
        # redirect to homepage if user has no rights to see this form
        return redirect(url_for('main.homepage'))

    else:
        if session['sees_timeline']:
            redir = '../aikajana'
        else:
            redir = '../'

        # render generic html body using jinja2 template (to be substituted to any page, not an independent form page)
        return render_template('forms/listaus.html',
            patient=patpat(person_id=session['person_id'], attr='henkilotunnus'),
            suku=patpat(person_id=session['person_id'], attr='lastname'),
            etu=patpat(person_id=session['person_id'], attr='firstname'),
            kuollut=patpat(person_id=session['person_id'], attr='death_date'),
            ika=patage(person_id=session['person_id']),
            default_page=redir,
            demographics_access=session['sees_demographics'],
            user_group=session['user_group_id']
        )



@forms_module.route('/_vastaukset', methods=['GET', 'POST'])
@login_required

def fetch_answers():
    """ get actual answers for selected form """
    user_answers = AllAnswers.query\
        .filter((AllAnswers.person_id == session['person_id']) & (AllAnswers.form_id == request.form['forms']))\
        .order_by(AllAnswers.session_id, AllAnswers.open_ts, AllAnswers.form_id, AllAnswers.answer_set_id)\
        .all()

    answers = ''

    answer_query_fields = {
        'open_ts': fields.String,
        'answer_content': fields.String,
        'answer_set_id': fields.String
    }

    if user_answers:
        answers = jsonify(marshal(user_answers, answer_query_fields))

    return answers



@forms_module.route('/_vastattu', methods=['GET', 'POST'])
@login_required

def fetch_answered():
    """ get actual answers for selected form """
    user_answers = AnswerSets.query\
        .filter((AnswerSets.person_id == session['person_id']) & (AnswerSets.save_ts != None) & (AnswerSets.user_group_id == session['user_group_id']))\
        .order_by(AnswerSets.open_ts.desc(), AnswerSets.save_ts.desc(), AnswerSets.answer_set_id, AnswerSets.form_name)\
        .all()
    
    answers = ''

    answer_query_fields = {
        'open_ts': fields.String,
        'save_ts': fields.String,
        'form_fullname': fields.String,
        'answer_set_id': fields.String
    }

    if user_answers:
        answers = jsonify(marshal(user_answers, answer_query_fields))

    return answers



@forms_module.route('/_check', methods=['POST'])
@login_required

def check_privileges():
    """ get privileges for view, insert and modify """
    form_privs = form_rights(session['user_group_id'], request.form['id'], session['person_id'])
    return jsonify(form_privs)



@forms_module.route('/edit/<lomake_id>/<vastaukset_id>', methods=['GET'])
@login_required

def editable_form(lomake_id, vastaukset_id):
    """ load dynamic form and fill it with answers that can be edited """
    
    # fallback for accessing the form with url manually
    form_privs = form_rights(session['user_group_id'], lomake_id, session['person_id'])
    if form_privs['modify_privilege'] is False:
        # redirect to homepage if user has no rights to see this form
        return redirect(url_for('main.homepage'))

    else:
        session['filling_form'] = lomake_id
        session['filling_time'] = cur_time()

        # save session to db
        ses = AnswerSet(session_id=session['session_id'], number=1, form_id=session['filling_form'], open_ts=session['filling_time'])
        DB.session.add(ses)
        DB.session.flush()
        session['answer_set_id'] = ses.answer_set_id
        DB.session.commit()

        try:
            form = generate_form(lomake_id, "edit", vastaukset_id)
            fallback = False
        except:
            form = FormTemplate()
            fallback = True
            raise Exception('No fields on form')

        # get form info
        form_info = DB.session.query(VForms)\
            .filter(VForms.form_id == lomake_id)\
            .first()

        # empty form fallback
        if fallback:
            redir = '../../'

        elif session['sees_timeline']:
            redir = '../../listaus/' + lomake_id
        else:
            redir = '../../'

        if session['sees_confirmation']:
            success = '../../success'
        else:
            success = redir

        # render generic html body using jinja2 template (to be substituted to any page, not an independent form page)
        return render_template('forms/muokkaus.html',
            form=form,
            patient=patpat(person_id=session['person_id'], attr='henkilotunnus'),
            suku=patpat(person_id=session['person_id'], attr='lastname'),
            etu=patpat(person_id=session['person_id'], attr='firstname'),
            kuollut=patpat(person_id=session['person_id'], attr='death_date'),
            ika=patage(person_id=session['person_id']),
            default_page=redir,
            success_page=success,
            name=form_info.__dict__['form_name'],
            header=form_info.__dict__['form_header'] or '',
            footer=form_info.__dict__['form_footer'] or '',
            user_group=session['user_group_id'],
            answer_set=ses.answer_set_id
        )
