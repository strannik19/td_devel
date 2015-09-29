#!/usr/bin/env python

##########################################################################
#    tptbinrc.py
#    Copyright (C) 2015  Andreas Wenzel (https://github.com/tdawen)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
##########################################################################


#
# If you don't have any relationship with Teradata, you will find this tool
# probably not very useful.
#

import struct
import sys
import tptbin
import logging

if len(sys.argv) == 1:
    logging.error("Filename(s) missing in command argument")
    sys.exit(1)

totalrowcount = 0

for filename in sys.argv[1:]:

    try:
        f = open(filename, "rb")
    except IOError as e:
        logging.warning("File: %s: I/O error(%d): %s", filename, e.errno,
                        e.strerror)
        break

    rowcounter = 0

    while True:
        rowlen = tptbin.readrowlen(f)

        if rowlen < 0:
            rowcounter += 1
            totalrowcount += 1

            logging.warning("File: %s: Record: %d: Error in len!",
                            filename, rowcounter)
            break
        elif rowlen > 0:
            rowcounter += 1
            totalrowcount += 1

            if tptbin.readahead(f, rowlen) == False:
                logging.warning("File: %s: Record: %d: Expected rowlen " \
                                "and actually read rowlen don't match!",
                                filename, rowcounter)
                break

        elif rowlen == 0:
            break

    if len(sys.argv) > 2:
        print rowcounter, filename
    else:
        print rowcounter

    f.close()

if len(sys.argv) > 2:
    print totalrowcount, "Total"
