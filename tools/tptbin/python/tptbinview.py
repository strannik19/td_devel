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
