#!/usr/bin/env python

##########################################################################
#    tptbin.py
#    Copyright (C) 2015  Andreas Wenzel (https://github.com/awenny)
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
import logging

def readrowlen (f):
    try:
        a = f.read(2)
    except:
        return (-1)

    if len(a) == 2:
        rowlen = struct.unpack('H', a)[0]
        if rowlen < 2:
            return (-1)
    elif len(a) == 0:
        return (0)
    else:
        return (-1)

    return (rowlen)


def readahead (f, rowlen):
    completerow = f.read(rowlen)

    if (len(completerow) != rowlen):
        return (False)

    return (True)


def readrow (f, rowlen, numrow):
    completerow = f.read(rowlen)

    if (len(completerow) != rowlen):
        logging.warning("File: %s: Record: %d: Error in len!",
                     filename, numrow)
        return (False)

    return (completerow)


def checkindicatorifcolumnisnull (indicators, pos):
    return indicators & 2**pos != 0


def numcolumns (filename, record, indicator, rownum, source):
    recordlen = len(record)
    columns = 0
        
    if indicator == 1:
        # data has indicator (at least one ... start with second position)
        indicatorpos = 1

        while True:
            # find number of indicator bytes

            if len(record[indicatorpos:indicatorpos + 2]) == 2:
                columnsize = struct.unpack('H',
                                      record[indicatorpos:indicatorpos + 2])[0]
            else:
                columns = False
                break

            if columnsize > recordlen - indicatorpos - 2:
                # columnsize is bigger than remaining record
                # this is definitely still an indicator byte on indicatorpos
                indicatorpos += 1
                continue

            # Start point for possible columns
            pos = indicatorpos
            columns = 0

            while True:
                columnsize = struct.unpack('H', record[pos:pos + 2])[0]

                columns += 1

                if (columns + 7) % 8 == 0:
                    # save the current indicator byte in integer depending
                    # on current column number for later usage
                    a = int((columns + 7) / 8) - 1
                    indi = struct.unpack('B',
                                     record[a:a+1])[0]
                    bitpos = (columns + 7) % 8 + 1

                if columnsize > recordlen - pos - 2:
                    # columnsize is too big for record. Wrong indicatorpos
                    columns = -1
                    break
                elif columnsize == recordlen - pos - 2:
                    # last column in record and reached correct end
                    # this is the only clean exit from this loop
                    break
                else:
                    # after columnsize there is still room in record
                    pos += columnsize + 2

                    # check if column content and indicator express same
                    if checkindicatorifcolumnisnull (
                        indi, bitpos) and columnsize == 0:
                        # ok
                        pass
                    elif not checkindicatorifcolumnisnull (
                        indi, bitpos) and columnsize > 0:
                        # ok
                        pass
                    else:
                        columns = -1
                        break

            if columns > 0:
                # wow, number of columns found
                # still do some checks
                if int((columns + 7) / 8) == indicatorpos:
                    # number of indicator bytes match number of columns
                    break
                else:
                    # number of indicator bytes do not match number of
                    # columns .. go to next indicator position
                    indicatorpos += 1
            else:
                # did not find correct number of columns try next
                # indicator
                indicatorpos += 1

    elif indicator == 2:
        # data has no indicator
        pos = 0

        while pos < recordlen:
            # still not at the end of the record
            columnsize = struct.unpack('H', record[pos:pos + 2])[0]

            pos += 2

            if pos + columnsize < recordlen:
                # column is as long as expected (last column)
                columns += 1
                pos += columnsize
            elif pos + columnsize > recordlen:
                # error (columnsize bigger zero but not as big as expected)
                columns = -1
                if source == 0:
                    logging.warning("File: %s, Error in row %d, "
                                    "column %d. Found %d bytes "
                                    "instead of %d!", filename, rownum,
                                    columns, len(column), columnsize)
                break
            else:
                # sum of columns equals expected record length
                columns += 1
                break

    else:
        # no indicator information given (indicator is unknown)
        # trying first without indicator
        columns = numcolumns (filename, record, 2, rownum, 1)
        
        if columns < 0:
            # no result, try with indicator now
            logging.debug("File: %s, Row %d, no indicator ... "
                          "trying with indicator", filename, rownum)
            columns = numcolumns (filename, record, 1, rownum, 1)

    return (columns)
