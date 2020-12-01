"""
PRELIMINARY LIBRARIES AND CONFIGURATION
"""

# import variable functions and formats
import collections

# redirecting and rendering functionality from Flask library
from flask import redirect, render_template, url_for, request, jsonify, session

# import login functions
from flask_login import login_required

# import RESTful classes
from flask_restful import fields, marshal

# SQLAlchemy
from sqlalchemy import func, or_

# import all from /timeline
from . import timeline_module

# import useful methods
from ..methods import patpat, patage, form_rights

# import database settings and classes
from ..models import UroJana, Answers, AllAnswers, TimelineHelp, LabCheck, SignificanceGroups, EpicScores

# import classes to populate forms itself from database table
from ..models import VForms



@timeline_module.route('/aikajana', methods=['GET', 'POST'])
@login_required

def timeline_show():
    """ patient timeline page """
    #if not session['sees_timeline']:
        # redirect to homepage if user has no rights to see this form
    #    return redirect(url_for('main.homepage'))
    #else:
    # figure out which forms to be shown to current user
    children = VForms.query\
        .filter((VForms.owner_group_id == session['user_group_id']) & (VForms.parent_form_id == session['child_id']))\
        .with_entities(VForms.form_name, VForms.form_id)\
        .order_by(VForms.form_number)\
        .all()
    chldrn = collections.OrderedDict(children)

    # figure out if forms has already been answered for current patient
    # TODO: change this to get_privileges(group_id, from_id) postgres function
    answered_forms = Answers.query\
        .filter(func.upper(Answers.henkilotunnus) == func.upper(patpat(person_id=session['person_id'], attr='henkilotunnus')))\
        .distinct(Answers.form_id)\
        .with_entities(Answers.form_id)\
        .group_by(Answers.form_id)\
        .all()
    answered_forms = [r for r, in answered_forms]

    # generate link buttons
    links = ''
    for (name, i) in chldrn.items():
        # get privileges for view, insert and modify
        dict_privs = form_rights(session['user_group_id'], i, session['person_id'])

        # generate links
        links += "<a href='#' class='formlink' rel='" + name\
            + "' id='" + str(i)\
            + "'><button type='button' id='" + str(i)\
            + "' class='btn btn-danger"
        if not dict_privs['insert_privilege']:
            links += " no-can-do disabled"
        links += "'"

        # additional tooltip button if answered forms are found
        if i in answered_forms and (dict_privs['view_privilege'] or dict_privs['modify_privilege']):
            links += """ data-content="<a href='#' class='tooltip-link' rel='""" + name\
                + """' id='""" + str(i)\
                + """'><button class='btn btn-success btn-sm tooltip-btn'>Täytetyt lomakkeet</button></a>" data-placement='bottom'"""
        links += ">" + name + "</button></a>"

    # get help page
    if TimelineHelp.query.first():
        helppi = TimelineHelp.query.with_entities(TimelineHelp.content).first()[0]
    else:
        helppi = ''

    # render template
    return render_template('timeline/aikajana.html',
        title='Potilaan aikajana',
        formlinks=links,
        group=session['user_group'],
        view=session['rootform'],
        child=session['child'],
        help=helppi,
        patient=patpat(person_id=session['person_id'], attr='henkilotunnus'),
        suku=patpat(person_id=session['person_id'], attr='lastname'),
        etu=patpat(person_id=session['person_id'], attr='firstname'),
        kuollut=patpat(person_id=session['person_id'], attr='death_date'),
        ika=patage(person_id=session['person_id']),
        timeline_access=session['sees_timeline'],
        demographics_access=True #session['sees_demographics']
    )



@timeline_module.route('/_hae_janatiedot', methods=['GET', 'POST'])
@login_required

def get_timeline_elements():
    """ get patient data from 'uromart' to draw timeline elements """
    if session['sees_timeline']:
        jana_elementit = UroJana.query\
            .filter((UroJana.person_id == session['person_id']) & (UroJana.start is not None))\
            .order_by(UroJana.start)\
            .all()
    else:
        jana_elementit = None

    # TODO: make dynamic which forms are not supposed to be shown on timeline
    vastaus_elementit = AllAnswers.query\
        .filter((AllAnswers.person_id == session['person_id']) & (AllAnswers.form_id != 15))\
        .order_by(AllAnswers.open_ts)\
        .all()

    # if something is returned, then marshal comfortable object to be substituted to front-end
    jsonresp = ''

    urojana_query_fields = {
        'element_id': fields.Integer,
        'start': fields.DateTime(dt_format='iso8601'),
        'end_ts': fields.DateTime(dt_format='iso8601'),
        'className': fields.String,
        'eventinfo': fields.String,
        'tooltip': fields.String,
        'icon_text': fields.String,
        'group': fields.String
    }

    vastaus_query_fields = {
        'open_ts': fields.DateTime(dt_format='iso8601'),
        'person_id': fields.Integer,
        'session_id': fields.Integer,
        'form_id': fields.Integer,
        'answer_content': fields.String
    }

    if (jana_elementit and not vastaus_elementit):
        jsonresp = jsonify(events=marshal(jana_elementit, urojana_query_fields), answers='')
    elif (not jana_elementit and vastaus_elementit):
        jsonresp = jsonify(events='', answers=marshal(vastaus_elementit, vastaus_query_fields))
    elif (jana_elementit and vastaus_elementit):
        jsonresp = jsonify(events=marshal(jana_elementit, urojana_query_fields), answers=marshal(vastaus_elementit, vastaus_query_fields))
    return jsonresp



@timeline_module.route('/_get_sig', methods=['GET'])
@login_required

def get_significances():
    """ get significance groups """
    sigs = SignificanceGroups.query\
        .order_by(SignificanceGroups.significance_id)\
        .with_entities(SignificanceGroups.significance_id, SignificanceGroups.significance)\
        .all()

    if sigs:
        jsonresp = jsonify(sigs)
    else:
        jsonresp = ''
    return jsonresp



@timeline_module.route('/_lab_autocomplete', methods=['GET'])
@login_required

def autocomplete():
    """ search-as-you-type functionality for lab tests """
    search = request.args.get('q')
    ltests = LabCheck.query\
        .filter((LabCheck.test).ilike('%' + str(search) + '%') & (LabCheck.person_id == session['person_id']))\
        .with_entities(LabCheck.test, LabCheck.unit)\
        .all()
    return jsonify(ltests)



@timeline_module.route('/_hae_labratiedot', methods=['POST'])
@login_required

def lab_values():
    """ lab values """
    selected_lab_test = request.form.to_dict()
    lresults = LabCheck.query\
        .filter((selected_lab_test['ltest'] == LabCheck.test + " (" + LabCheck.unit + ")") & (LabCheck.person_id == session['person_id']))\
        .with_entities(LabCheck.result, LabCheck.start_ts)
    return jsonify(lresults.all())



@timeline_module.route('/_hae_epictiedot', methods=['GET'])
@login_required

def epic_values():
    """ epic values """
    # TODO: add sub-score indicator
    eresults = EpicScores.query\
        .filter((or_(EpicScores.series_group == 'EPIC keskeiset', EpicScores.series_group == 'IPSS')) & (EpicScores.person_id == session['person_id']))\
        .with_entities(EpicScores.value, EpicScores.series_name, EpicScores.ts)
    return jsonify(eresults.all())
