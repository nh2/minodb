#!/usr/bin/env python

"""
Usage:
- python batch-fill.py [DB_URL] [MYDATA.json]
E.g.:
- python batch-fill.py http://minodb.example.com mydata.json

Fills the minodb behind the URL with the data in the given JSON file.
The JSON file is expected to be a list of objects to be put into the DB.

Requirements:
- the Python 'requests' package (e.g python-requests on Debian)
"""

import sys
import json
import requests

db_url = sys.argv[1]
json_file = sys.argv[2]

with open(json_file) as f:
    data = json.loads(f.read())
    for d in data:
        print d
        requests.post(db_url + '/put', data=d)
