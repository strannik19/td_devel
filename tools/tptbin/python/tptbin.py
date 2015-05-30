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

def readrowlen(f):
     try:
         a = f.read(2)
     except:
         return (-1)
 
     if len(a) == 2:
         rowlen = struct.unpack('H', a)[0]
     else:
         return (-1)

     return (rowlen)


def readrow(f, rowlen, numrow):
    completerow = f.read(rowlen)

    if (len(completerow) != rowlen):
        logging.warning("File: %s: Record: %d: Error in len!",
                        filename, numrow)
        return (False)

    return (completerow)


def numcolumns(filename, record, indicator, rownum):
    recordlen = len(record)
    columns = 0

    if indicator == 1:
        # data has indicator
        pass

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
