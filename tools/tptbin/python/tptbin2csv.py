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

    while True:
        try:
            a = f.read(2)
        except:
            break
    
        if len(a) == 2:
            recordlen = struct.unpack('H', a)[0]
        else:
            break

        if recordlen > 0:
            completerecord = f.read(recordlen)
            if (len(completerecord) == recordlen):
                # read as much byte from file as recordlen in file defined
                numcolumns = tptbin.numcolumns(filename, completerecord, indicator)
            else:
                sys.stderr.write("File: {0}: Record: {1}: Error in len!", filename, record)
                break

        print numcolumns

    f.close()
