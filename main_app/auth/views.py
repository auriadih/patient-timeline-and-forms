""" authentication module """

# AD stuff
from base64 import b64encode
from requests import Session as reqses
from requests.packages import urllib3
try:
    from ..acitools import ad_login
except ImportError:
    from ..demotools import ad_login

# redirecting and rendering functionality from Flask library
from flask import redirect, render_template, url_for, request, jsonify, session

# import login library
from flask_login import login_required, login_user, logout_user

# import fields used in auth module forms
from wtforms.fields import StringField, SubmitField, SelectField
from wtforms import validators

# SQLAlchemy
from sqlalchemy import func

# import user session / login module
from . import auth_module

# import method for getting current time in suitable format
from ..methods import cur_time

# import login form and plain form template
from .forms import LoginForm
from ..forms.forms import FormTemplate

# import database connection classes
from .. import DB

# import database models used in auth module
from ..models import User, UserGroups, VForms, Session, PATTAULU, AIKAJANA, FORMIT, MARTTI, BASE



# make session permanent; it would be cleared only on logout
@auth_module.before_request
def session_management():
    """ make session permanent """
    session.permanent = True



# define login page
@auth_module.route('/login', methods=['GET', 'POST'])

def login():
    """ login form """
    form = LoginForm()
    return render_template('auth/login.html', login=form)



@auth_module.route('/_login', methods=['POST'])

def check_login_type():
    """We can login with username/password or with CAS-card "VRK-kortti"
    We use the serialNumber from client certificates DN-field if logging on with CAS-card,
    otherwise use username/password)
    """

    try:
        dn_from_request = request.environ['HTTP_X_SSL_CLIENT_S_DN']
    except:
        # No valid client certificate
        dn_from_request = None

    if not dn_from_request:
        # No certificate given
        return(adcheck())

    # Example of DN: 'CN=Smith Bill 12345678901,SN=Smith,GN=Bill,serialNumber=12345...
    # Convert DN to list, split it and make dictionary:
    try:
        dn_list = dn_from_request.split(',')
        dn_dict = {i.split('=')[0]:i.split('=')[1] for i in dn_list}
        serial_number = dn_dict['serialNumber']
        return(adcheck(serial_number))

    except:
        # Can not proceed with CAS login
        return(adcheck())


def adcheck(serial_number = None):
    """ check if user email and password matches ones in AD, 
    then proceed login process """

    if request.method == 'POST':
        # TODO-demo
        """ You should implement your own authentication module.
        We used an external service with secure connection.
        Response to username + password = status 200 means authentication verified
        """
        if not serial_number:
            username_string = request.form['username']
            password = request.form['password']
            # Check login, create your own function/module to do this!
            status_code = ad_login(username_string, password)
        else:
            status_code = 401

        # if user authenticated, now check authorization
        if status_code == 200 or serial_number:
            # TODO: get member list from AD and use it for different views
            #memberOf = json.loads(ad_login.text)['members']

            # get user id, either via CAS serial number or username
            if serial_number:
                user_id = str(User.query.filter(User.serial_number == serial_number).first())
            else:
                user_id = str(User.query.filter(User.username == func.upper(username_string)).first())

            if user_id != 'None':    # if user found in authorization database

                # fresh session
                session.clear()
                session['logging_in'] = user_id
                session['sees_timeline'] = False
                session['sees_demographics'] = False
                session['sees_confirmation'] = False
                session['sees_filled_forms'] = False
                session['person_id'] = None

                # get user group membership info
                user_groups = UserGroups.query\
                    .filter(UserGroups.app_user_id == session['logging_in'])\
                    .with_entities(UserGroups.group_id, UserGroups.group_name)\
                    .all()
                dict_groups = [r for r in user_groups]

                # if multiple groups defined for user, show selection form
                if len(user_groups) > 1:
                    # summon empty pseudo-form
                    class Groups(FormTemplate):
                        """ initiate form template """
                        pass

                    # populate form with group field if match is found from database
                    if user_groups:
                        setattr(Groups, 'Erikoisala', SelectField(label='Erikoisala', id='specialty', choices=[('', '')] + user_groups, validators=[validators.Required()]))
                        form = Groups()

                    # render template with form
                    return render_template('baseform.html', form=form)

                # if exactly one group defined for user, set that to session and proceed
                elif len(user_groups) == 1:
                    return group_roots(grp=dict_groups[0][1], gid=dict_groups[0][0])

                # fallback - if no groups are found for user
                else:
                    # render 'formi' template with error
                    return render_template('baseform.html', err='Käyttäjälle ei ole määritelty erikoisaloja')

            else:   # user_id = 'None', ie user not authorized
                err_message = 'Käyttöoikeus puuttuu'

        # if login fails
        else:
            # is user is not added to database
            if User.query.filter(User.username == func.upper(username_string)).with_entities(User.username).all():
                err_message = 'Väärä salasana'
            # if user is found but password doesn't match
            else:
                err_message = 'Käyttäjätunnusta ei löydy'

        return jsonify({'usr': username_string, 'err': err_message}), status_code



@auth_module.route('/_roots', methods=['POST'])

def group_roots(grp=0, gid=0):
    """ check which views user is allowed to see/use """
    if grp != 0 and gid != 0:
        group = str(grp)
        group_id = str(gid)
    else:
        group = str(request.form.to_dict()['group'])
        group_id = str(request.form.to_dict()['group_id'])

    # save user group to global session variable
    session['user_group'] = group
    session['user_group_id'] = group_id

    # get user root forms
    user_roots = VForms.query\
        .filter((VForms.owner_group_id == group_id) & (VForms.is_root_form))\
        .with_entities(VForms.form_id, VForms.form_name)\
        .all()
    dict_roots = [r for r in user_roots]

    # if more than one group is defined for user, show a form
    if len(user_roots) > 1:
        # summon empty pseudo-form
        class Roots(FormTemplate):
            """ initiate form object """
            pass

        # populate form with view field if match is found from database
        if user_roots:
            setattr(Roots, 'Näkymä', SelectField(label='Näkymä', id='view', choices=[('', '')] + user_roots, validators=[validators.Required()]))
            form = Roots()

        # render 'formi' template with form
        return render_template('baseform.html', form=form)

    # if exactly one group defined for user, set that to session and proceed
    elif len(user_roots) == 1:
        return selected_root(grp=group, gid=group_id, rform=dict_roots[0][1], rfid=dict_roots[0][0])

    # fallback - if no groups are found for user
    else:
        # render 'formi' template with error
        return render_template('baseform.html', err='Käyttäjälle ei ole määritelty näkymiä')



@auth_module.route('/_root', methods=['POST'])

def selected_root(grp=0, gid=0, rform=0, rfid=0):
    """ save selected 'view' to global session variable """
    if grp != 0 and gid != 0 and rform != 0 and rfid != 0:
        group = str(grp)
        group_id = str(gid)
        rootform = str(rform)
        rootform_id = str(rfid)
    else:
        group = str(request.form.to_dict()['group'])
        group_id = str(request.form.to_dict()['group_id'])
        rootform = str(request.form.to_dict()['rootform'])
        rootform_id = str(request.form.to_dict()['rootform_id'])

    session['user_group'] = group
    session['user_group_id'] = group_id
    session['rootform'] = rootform
    session['rootform_id'] = rootform_id

    # add row to database
    ses_start = cur_time()
    ses = Session(
        app_user_id=session.get('logging_in'),
        group_id=group_id,
        person_id=session.get('person_id') or None,
        session_started_ts=ses_start
    )
    DB.session.add(ses)
    DB.session.commit()

    # log user in (this writes to session['user_id'])
    login_user(User.query.get(int(session['logging_in'])))

    # fetch database determined incrementing session id number
    current_session = Session.query\
        .filter(Session.session_started_ts == ses_start)\
        .with_entities(Session.session_id)\
        .first()
    session['session_id'] = current_session

    # check which features user is allowed to access
    feature_access = DB.engine.execute("select feature_name from " + BASE + ".get_feature_access(" + session['user_group_id'] + ");")
    for row in feature_access:
        if row[0] == 'timeline':
            session['sees_timeline'] = True
        elif row[0] == 'demographics':
            session['sees_demographics'] = True
        elif row[0] == 'confirmation_page':
            session['sees_confirmation'] = True
        elif row[0] == 'filled_form_list':
            session['sees_filled_forms'] = True

    # return suitable HTTP status code
    return 'redirect', 200



@auth_module.route('/logout', methods=['GET', 'POST'])
@login_required

def logout():
    """ define logout request """
    # add timestamp to database for closing session
    Session.query\
        .filter((Session.session_id == session['session_id']))\
        .update({'session_ended_ts': (cur_time())})
    DB.session.commit()

    # log user out
    logout_user()

    # end session (empty global 'session' variable)
    session.clear()

    # redirect to homepage
    return redirect(url_for('main.homepage'))



@auth_module.route('/potilas', methods=['GET', 'POST'])
@login_required

def patient():
    """ patient search """
    # summon empty pseudo-form
    class PotilasHaku(FormTemplate):
        """ initiate form object """
        pass

    # create fields for searching patients
    setattr(PotilasHaku, 'Henkilötunnus', StringField(label='Henkilötunnus', id='hetu', validators=[validators.Required()]))
    setattr(PotilasHaku, 'Hae', SubmitField(label='Hae', id='hae'))
    form = PotilasHaku()

    # load template
    return render_template('auth/potilas.html', pot=form, title='Potilashaku')



@auth_module.route('/_potilas', methods=['POST'])

def check_patient():
    """ check if searched patient is found from the db, then proceed """
    # get user entered patient from page
    hetu = str(request.form.to_dict()['Henkilötunnus'])

    # mark session start on clicking submit button (current time)
    ses_start = cur_time()

    # check that schema exists
    schema_found = DB.engine.execute("SELECT schema_name FROM information_schema.schemata WHERE schema_name = '" + str(MARTTI) + "';")

    if schema_found.rowcount > 0:
        # use custom db function to return patient ID if patient is in db or null if not valid hetu
        db_person_id = DB.session.query(eval("func." + BASE + ".insert_person('" + hetu + "')")).scalar()

        # if person id is available, update session variable
        if db_person_id:
            session['person_id'] = db_person_id

            # end current session with current individual patient
            Session.query\
                .filter((Session.session_id == session['session_id']))\
                .update({'session_ended_ts': ses_start})

            # add new session regarding individual patient
            ses = Session(
                app_user_id=session['user_id'],
                group_id=session['user_group_id'],
                person_id=session['person_id'],
                session_started_ts=ses_start
            )
            DB.session.add(ses)
            DB.session.commit()

            # fetch database determined incrementing session id number
            current_session = Session.query\
                .filter(Session.session_started_ts == ses_start)\
                .with_entities(Session.session_id)\
                .first()
            session['session_id'] = current_session

            # return boolean value to front-end
            return jsonify(True)

        # return boolean value to front-end
        return jsonify(False)
    else:
        return jsonify(False, "Schema " + MARTTI + " not found. Contact your DBA.")
