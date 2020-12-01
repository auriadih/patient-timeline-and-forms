""" main module initialization """

from flask import Blueprint

main_module = Blueprint('main', __name__)

from . import views
