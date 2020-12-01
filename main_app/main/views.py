"""
PRELIMINARY LIBRARIES AND CONFIGURATION
"""

# redirecting and rendering functionality from Flask library
from flask import redirect, render_template, url_for, request, jsonify, session, current_app

# import login functions
from flask_login import login_required, current_user

# import RESTful classes
from flask_restful import fields, marshal

# SQLAlchemy
from sqlalchemy import func

# import all from /main
from . import main_module

# import useful methods
from ..methods import patpat, patage

# import database settings and classes
from ..models import Answers

# import classes to populate forms itself from database table
from ..models import VForms


import urllib.request, json




@main_module.route('/')

def homepage():
    """ home page """
    if current_user.is_authenticated:
        # figure out which forms to be shown to current user
        form_query = VForms.query\
            .filter((VForms.owner_group_id == session['user_group_id']) & (VForms.parent_form_id == session['rootform_id']))\
            .order_by(VForms.form_id)
        children = form_query\
            .with_entities(VForms.form_name, VForms.form_id, VForms.is_leaf_form)\
            .all()

        if all(form_is_leaf_form[2] == True for form_is_leaf_form in children):
            session['child_id'] = session['rootform_id']
            session['child'] = session['rootform']
            return redirect(url_for('timeline.timeline_show'))


        if str(form_query.first()) != str(None):
            links = []
            ids = []
            action = []
            for i in children:
                links.append(i[0])
                ids.append(i[1])
                action.append(i[2])

            # render home page for authenticated users
            return render_template('home/index.html',
                patient=patpat(person_id=session['person_id'], attr='henkilotunnus'),
                suku=patpat(person_id=session['person_id'], attr='lastname'),
                etu=patpat(person_id=session['person_id'], attr='firstname'),
                kuollut=patpat(person_id=session['person_id'], attr='death_date'),
                ika=patage(person_id=session['person_id']),
                title=session['rootform'],
                forms=links,
                group=session['user_group'],
                view=session['rootform'],
                destination=action,
                form_id=ids,
                demographics_access=True, # set this always true, so a hoitaja can see the hetu for confirmation; otherwise: session['sees_demographics']
                user_group=session['user_group_id'])

        # redirect to /lomake/<id>/
        else:
            return redirect(url_for('dynamic_form', lomake_id=session['rootform_id'], user_group=session['user_group_id']))

    else:
        # render home page for visitors
        return render_template('home/index.html', title='Etusivu')



@main_module.route('/_child', methods=['POST'])
@login_required

def selected_child():
    """ save selected sibling form to global 'session' variable """
    session['child'] = str(request.form.to_dict()['child'])
    session['child_id'] = request.form.to_dict()['child_id']

    return('Success', 200)



@main_module.route('/_demoanswers', methods=['GET'])
@login_required

def answered_demo_fields():
    """ get certain field data from answered forms """
    # TODO: make dynamic
    last_demo_answers = Answers.query\
        .filter((func.upper(Answers.henkilotunnus) == func.upper(patpat(person_id=session['person_id'], attr='henkilotunnus')))\
            & (Answers.form_id == 8)\
            & (Answers.field_id.in_([2, 9, 10])))\
        .with_entities(Answers.field_id,\
            func.max(Answers.open_ts).label('last_ts'))\
        .group_by(Answers.field_id)\
        .subquery()

    demo_answers = Answers.query\
        .filter((func.upper(Answers.henkilotunnus) == func.upper(patpat(person_id=session['person_id'], attr='henkilotunnus')))\
            & (Answers.form_id == 8)\
            & (Answers.field_id.in_([2, 9, 10]))\
            & (Answers.field_id == last_demo_answers.c.field_id)\
            & (Answers.open_ts == last_demo_answers.c.last_ts))\
        .order_by(Answers.field_id)\
        .all()

    answer_fields = {
        'field_id': fields.String,
        'field_name': fields.String,
        'choice_name': fields.String,
        'open_ts': fields.DateTime
    }

    # if something is returned, then jsonify to front-end
    return jsonify(answers=marshal(demo_answers, answer_fields))



@main_module.route('/raportit', methods=['GET'])
@login_required

def report_wrapper():
    """TODO-demo 
    Do user authentication etc. to show specific reports.
    In stats.html is an example how you could include a shinyproxy report"""

    http_host = 'https://' + request.headers.get('Host')
    redir = './'

    return render_template('forms/stats.html', 
                            default_page=redir, 
                            demographics_access=False, 
                            base_url=http_host, 
                            report_path = current_app.config['REPORT_PATH'],
                            user_group=session['user_group_id'])
