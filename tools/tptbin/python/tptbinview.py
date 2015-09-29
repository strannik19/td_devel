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
import argparse
import curses

#logging.basicConfig(level=logging.DEBUG)

parser = argparse.ArgumentParser()
group = parser.add_mutually_exclusive_group()
group.add_argument("-i", help="data file(s) have indicator bits",
                    action="store_true")
group.add_argument("-ni", help="data file(s) have no indicator bits",
                    action="store_true")
parser.add_argument("-q", "--quick", help="Quickscan (check only first record per file)",
                    action="count")
parser.add_argument("FILE", help="File in tptbin format", nargs="+")
args = parser.parse_args()

if args.ni == True:
    # we know, there are no indicator bits in the data
    indicator = 2
elif args.i == True:
    # we know, there are indicator bits in the data
    indicator = 1
else:
    # we don't know if there are or there are no indicator bits in the data
    indicator = 0

stdscr = curses.initscr()
curses.noecho()
curses.cbreak()
stdscr.keypad(1)

for filename in args.FILE:

    try:
        f = open(filename, "rb")
    except IOError as e:
        logging.warning("File: %s: I/O error(%d): %s", filename, e.errno,
                        e.strerror)
        break

    oldnumcolumns = 0
    numrow = 0
    oldnumrow = 1

    while True:
        rowlen = tptbin.readrowlen(f)
    
        if rowlen > 0:
            numrow += 1

            completerecord = tptbin.readrow(f, rowlen, numrow)
            if completerecord != False:
                numcolumns = tptbin.numcolumns(filename, completerecord,
                                               indicator, numrow, 0)
            else:
                break
        else:
            break

        if numrow == 1:
            oldnumcolumns = numcolumns

        if oldnumcolumns != numcolumns and numrow > 1:
            print "{0}: {1} - {2}: {3}".format (filename, oldnumrow, numrow,
                                                oldnumcolumns)
            oldnumrow = numrow

        if args.quick == 1:
            break
        elif 10 ** args.quick == numrow:
            break

    print "{0}: {1} - {2}: {3}".format (filename, oldnumrow, numrow,
                                        oldnumcolumns)

    f.close()

curses.nocbreak()
stdscr.keypad(0)
curses.echo()
curses.endwin()
