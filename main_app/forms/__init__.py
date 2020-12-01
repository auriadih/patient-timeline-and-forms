""" forms module initialization """

from flask import Blueprint

forms_module = Blueprint('forms', __name__)

from . import views
