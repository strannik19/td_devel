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
import logging

def readrowlen (f):
     try:
          a = f.read(2)
     except:
          return (-1)
 
     if len(a) == 2:
          rowlen = struct.unpack('H', a)[0]
     else:
          return (-1)

     return (rowlen)


def readrow (f, rowlen, numrow):
     completerow = f.read(rowlen)

     if (len(completerow) != rowlen):
          logging.warning("File: %s: Record: %d: Error in len!",
                          filename, numrow)
          return (False)

     return (completerow)


def checkindicatorifcolumnisnull (indicators, pos):
     return indicators & 2**pos != 0


def numcolumns (filename, record, indicator, rownum):
     recordlen = len(record)
     columns = 0

     if indicator == 1:
          # data has indicator (at least one .. so start at position 1)
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

               column = record[pos:pos + columnsize]

               if (len(column) == columnsize):
                    # column is as long as expected
                    columns += 1
                    pos += columnsize
               elif len(column) > 0 and columnsize > 0:
                    # error (columnsize bigger zero but not as big as expected)
                    logging.warning("File: %s: Error in row %d, column %d. "
                                    "Found %d bytes instead of %d!", filename,
                                    rownum, columns, len(column), columnsize)
               else:
                    break

     else:
          # no indicator information given (indicator is unknown)
          # trying to find out
          pass

     return (columns)
