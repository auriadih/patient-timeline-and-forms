""" main app initialization """

# import timedelta
from datetime import timedelta
from os import path

# import Flask microframework and SQLAlchemy library for PostgreSQL connections
from flask import Flask, session
from flask_sqlalchemy import SQLAlchemy

# import user accounts library
from flask_login import LoginManager

# import Bootstrap template library
from flask_bootstrap import Bootstrap



# db connection initialization
DB = SQLAlchemy()
LOGIN_MANAGER = LoginManager()

def create_app():
    """ define main application """
	# initialize Flask app
    app = Flask(__name__, instance_relative_config=True)

    # fetch configuration
    app.config['DEBUG'] = True
    # Keep SQLALCHEMY_ECHO = False in production
    app.config['SQLALCHEMY_ECHO'] = False

    # fetch config file. Flask will search for files in instance folder
    if path.isfile(path.join("instance", "aciconfig.py")):
        config_file = "aciconfig.py"
    else:
        if path.isfile(path.join("instance", "democonfig.py")):
            config_file = "democonfig.py"
        else:
            config_file = "config.py"

    app.config.from_pyfile(config_file) # read from 'instance/[demo]config.py'

    # expire session in x minutes
    app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=120)

    # initialize db
    DB.init_app(app)

	# initialize login manager
    LOGIN_MANAGER.init_app(app)
    LOGIN_MANAGER.login_message = "Kirjaudu sisään nähdäksesi tämän sivun."
    LOGIN_MANAGER.login_view = "auth.login"

    # initiate Bootstrap environment
    Bootstrap(app)

    ## MANDATORY MODULES
	# import auth module
    from .auth import auth_module as auth_blueprint
    app.register_blueprint(auth_blueprint)

    # import main module
    from .main import main_module as main_blueprint
    app.register_blueprint(main_blueprint)

    ## OPTIONAL MODULES
    # import forms module
    from .forms import forms_module as forms_blueprint
    app.register_blueprint(forms_blueprint)

    # import timeline module
    from .timeline import timeline_module as timeline_blueprint
    app.register_blueprint(timeline_blueprint)

    # output
    return app
