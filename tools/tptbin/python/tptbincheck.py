#!/usr/bin/env python

#
# If you don't have any relationship with Teradata, you will find this tool
# probably not very useful.
#
# Copyright (c) 2015 Andreas Wenzel, Teradata Germany
# License: You are free to use, adopt and modify this program for your
# particular purpose.
# LICENSOR IS NOT LIABLE TO LICENSEE FOR ANY DAMAGES, INCLUDING COMPENSATORY,
# SPECIAL, INCIDENTAL, EXEMPLARY, PUNITIVE, OR CONSEQUENTIAL DAMAGES,
# CONNECTED WITH OR RESULTING FROM THIS LICENSE AGREEMENT OR LICENSEE'S USE OF
# THIS SOFTWARE.
#
# It is appreciated, if any changes to the source code are reported
# to the creator of this software.
#

import struct
import sys
import tptbin
import logging
import argparse

if len(sys.argv) == 1:
    logging.error("Filename(s) missing in command argument")
    sys.exit(1)

for filename in sys.argv[1:]:

    try:
        f = open(filename, "rb")
    except IOError as e:
        logging.warning("File: %s: I/O error(%d): %s", filename, e.errno, e.strerror)
        break

    indicator = 2
    oldnumcolumns = 0
    numrow = 0
    oldnumrow = 1

    while True:
        rowlen = tptbin.readrowlen(f)
    
        if rowlen > 0:
            numrow += 1

            completerecord = tptbin.readrow(f, rowlen, numrow)
            if (completerecord != False):
                # read as much byte from file as recordlen in file defined
                numcolumns = tptbin.numcolumns(filename, completerecord, indicator, numrow)
            else:
                break
        else:
            break

        if numrow == 1:
            oldnumcolumns = numcolumns

        if oldnumcolumns != numcolumns and numrow > 1:
            print "{0}: {1} - {2}: {3}".format (filename, oldnumrow, numrow, oldnumcolumns)
            oldnumrow = numrow

    print "{0}: {1} - {2}: {3}".format (filename, oldnumrow, numrow, oldnumcolumns)

    f.close()
