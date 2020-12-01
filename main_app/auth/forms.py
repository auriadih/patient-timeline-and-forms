""" auth module forms """

# import custom forms libraries
from flask_wtf import FlaskForm

# import classes for form field types
from wtforms import PasswordField, StringField, SubmitField 
from wtforms.validators import DataRequired

class LoginForm(FlaskForm):
    """ default login form """
    username = StringField('Käyttäjätunnus')
    password = PasswordField('Salasana')
    #username = StringField('Käyttäjätunnus', validators=[DataRequired()])
    #password = PasswordField('Salasana', validators=[DataRequired()])
    submit = SubmitField('Kirjaudu sisään')
    submit_vrk = SubmitField('Kirjaudu sisään VRK-kortilla')
