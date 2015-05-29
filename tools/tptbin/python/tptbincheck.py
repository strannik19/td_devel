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
import argparse

if len(sys.argv) == 1:
    sys.stderr.write("Filename(s) missing in command argument")
    sys.exit(1)

for filename in sys.argv[1:]:

    try:
        f = open(filename, "rb")
    except IOError as e:
        sys.stderr.write("File: {0}: I/O error({1}): {2}", filename, e.errno, e.strerror)
        break

    record = 0
    indicator = 2
    oldnumcolumns = 0;
    numrow = 0;
    oldnumrow = 1;

    while True:
        rowlen = tptbin.readrowlen(f)
    
        if rowlen > 0:
            completerecord = tptbin.readrow(f, rowlen)
            if (completerecord != False):
                # read as much byte from file as recordlen in file defined
                numcolumns = tptbin.numcolumns(filename, completerecord, indicator)
            else:
                break
        else:
            break

        if numrow == 0:
            oldnumcolumns = numcolumns

        numrow += 1

        if oldnumcolumns != numcolumns and numrow > 0:
            sys.stdout.write ("{0} .. {1}: {2}", oldnumrow, numrow - 1, oldnumcolumns)
            oldnumrow = numrow

    print "{0} - {1}: {2}".format(oldnumrow, numrow, oldnumcolumns)

    f.close()
