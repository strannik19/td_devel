#!/usr/local/bin/python

#
# Example of Python with Oracle Connector
#
# Usage of cx_Oracle with python:
# Download instant client from Oracle website and install it
# If not already done by installation routine, set environment variables
# as described on website.
# Execute "pip install cx_oracle"
#
# Tested with Oracle Database version 12.1.0.2.0, Client version 11.2.0.4.0
# Python 2.7.9 on Mac OS X Yosemite (homebrew)
#

import cx_Oracle

db = cx_Oracle.connect('username', 'password', 'tns or easy connect information')

print db.version

cursor = db.cursor()

cursor.execute('SELECT username FROM all_users')

for row in cursor:
	print row[0]

db.close()
