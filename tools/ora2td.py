#!/usr/local/bin/python

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
import argparse
import sys

parser = argparse.ArgumentParser(description='Unload data from an Oracle '
								 'database in a certain format and load it '
								 'to Teradata (optional).')
parser.add_argument('--fromdb', nargs=1, required=True,
					metavar='"From Oracle Schema"',
					help='Enter the Oracle Schema of the source table/view')
parser.add_argument('--fromtab', nargs=1, required=True,
					metavar='"From Oracle Table/View"',
					help='Enter the Oracle Table or View to read from')
parser.add_argument('--orausr', nargs=1, required=True,
					metavar='"Username in Oracle"',
					help='Enter the Oracle User to connect to')
parser.add_argument('--orapwd', nargs=1, required=True,
					metavar='"Password in Oracle"',
					help='Enter the Oracle Password to authenticate')
parser.add_argument('--oracle', nargs=1, required=True,
					metavar='"Oracle Address"',
					help='Enter the Oracle Address to connect to')
parser.add_argument('--todb', nargs=1, required=False,
					metavar='"To Terdata Database"',
					help='Enter the Teradata target Database')
parser.add_argument('--totab', nargs=1, required=False,
					metavar='"To Teradata Table"',
					help='Enter the Teradata Table to write to')
parser.add_argument('--tdusr', nargs=1, required=False,
					metavar='"Username in Teradata"',
					help='Enter the Teradata User to connect to')
parser.add_argument('--tdpwd', nargs=1, required=False,
					metavar='"Password in Teradata"',
					help='Enter the Teradata Password to authenticate')
parser.add_argument('--teradata', nargs=1, required=False,
					metavar='"Teradata Address"',
					help='Enter the Teradata Address to connect to')
parser.add_argument('-c', '--dropandcreateifexists', action='store_true',
					help='Drop target Teradata Table if exists and recreate')

args = parser.parse_args()

db = cx_Oracle.connect('username', 'password', 'tns or easy connect information')

#print db.version

#cursor = db.cursor()

#cursor.execute('SELECT username FROM all_users')

#for row in cursor:
#	print row[0]

#db.close()
