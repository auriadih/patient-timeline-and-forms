""" timeline module initialization """

from flask import Blueprint

timeline_module = Blueprint('timeline', __name__)

from . import views
