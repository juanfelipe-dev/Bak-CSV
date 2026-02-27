#!/usr/bin/env bash
# simple startup script for render.com
# install packages and run the flask app

set -e

# ensure dependencies installed (render will typically run pip install -r requirements.txt automatically)
# but we can include it for safety
pip install -r requirements.txt

# export flask environment variables
export FLASK_APP=export_bak.py
export FLASK_ENV=production

# run the application using gunicorn for production
exec gunicorn export_bak:app --bind 0.0.0.0:8000 --workers 4
