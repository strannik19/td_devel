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
    print "Missing file name(s)"
    sys.exit(1)

totalrowcount = 0

for filename in sys.argv[1:]:

    try:
        f = open(filename, "rb")
    except IOError as e:
        print "I/O error({0}): {1}".format(e.errno, e.strerror)
        break

    rowcounter = 0

    while True:
        rowlen = tptbin.readrowlen(f)

        if rowlen > 0:
            rowcounter += 1
            totalrowcount += 1
    
            completerecord = f.read(rowlen)
        else:
            break

    if len(sys.argv) > 2:
        print rowcounter, filename
    else:
        print rowcounter

    f.close()

if len(sys.argv) > 2:
    print totalrowcount, "Total"
