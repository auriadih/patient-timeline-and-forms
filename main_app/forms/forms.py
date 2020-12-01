""" forms module forms """

# import forms library
from flask_wtf import FlaskForm
from wtforms import HiddenField

class FormTemplate(FlaskForm):
    """ empty form template """
    dynamically_generated = HiddenField('Dynamically generated form')
