#!/bin/bash

# run_start.sh - simple helper for starting the Flask application
# usage: ./run_start.sh

# ensure we are in the project directory
cd "$(dirname "$0")" || exit 1

# optionally create a virtual environment if one doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python -m venv venv
fi

# activate the environment
# shellcheck disable=SC1091
source venv/bin/activate

# install requirements (first run or after changes)
pip install -r requirements.txt

# set FLASK environment variables
export FLASK_APP=export_bak.py
export FLASK_ENV=development

# start the server
flask run
