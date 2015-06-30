#!/usr/bin/python

#
# Sample script to demonstrate the REST API
# It connects to Teradata and selects dbc.dbcinfo
#

import json
import urllib2
import base64
import zlib
 
 
username = 'sysdba'
password = 'sysdba'
teradataDatabaseAlias = 'Teradata15VM'
 
 
# HTTP
# Connect to Teradata via REST

url = 'http://tdevm1500:1080/tdrest/systems/' + teradataDatabaseAlias + '/queries'
 
 
# HTTPS 
#url = 'https://tdevm1500:1443/tdrest/systems/' + teradataDatabaseAlias + '/queries'
 
 
# Setup required HTTP headers
headers={}
headers['Content-Type'] = 'application/json'
headers['Accept'] = 'application/vnd.com.teradata.rest-v1.0+json'
headers['Authorization'] = "Basic %s" % base64.encodestring('%s:%s' % (username, password)).replace('\n', ''); 
 
 
# Uncomment to receive results gzip compressed.
#headers['Accept-Encoding'] = 'gzip'
 
 
# Set query bands
queryBands = {}
queryBands['applicationName'] = 'MyApp'
queryBands['version'] = '1.0'
 
 
# Set request fields, including SQL.
data = {}
data['query'] = 'SELECT * FROM DBC.DBCInfo'
data['queryBands'] = queryBands
data['format'] = 'array'
 
 
# Build request.
request = urllib2.Request(url, json.dumps(data), headers)
 
 
#Submit request
try:
  response = urllib2.urlopen(request);
  # Check if result have been compressed.
  if response.info().get('Content-Encoding') == 'gzip':  
    response = zlib.decompress(response.read(), 16+zlib.MAX_WBITS)    
  else:
    response = response.read();
except urllib2.HTTPError, e:
    print 'HTTPError = ' + str(e.code)
    response = e.read();
except urllib2.URLError, e:
    print 'URLError = ' + str(e.reason)
    response = e.read();
 
 
# Parse response to confirm value JSON.
results = json.loads(response);
 
 
# Print formatted results
print json.dumps(results, indent=4, sort_keys=True)
 
 
# Do something with the result.
data = results['results'][0]['data']
for d in data:
    if d[0] == 'VERSION':
        print '\nThe version of the Teradata Database is ' + d[1]
    if d[0] == 'RELEASE':
      print '\nThe release level of the Teradata Database is ' + d[1]
