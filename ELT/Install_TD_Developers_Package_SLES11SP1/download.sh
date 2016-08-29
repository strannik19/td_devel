#!/usr/bin/env bash

##########################################################################
#    download.sh
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
# Download required free packages
#

ERRORPACKAGES=""

for DL in \
    http://ftp.fau.de/apache/apr/apr-1.5.2.tar.bz2 \
    http://ftp.fau.de/apache/apr/apr-util-1.5.4.tar.bz2 \
    http://curl.haxx.se/download/curl-7.47.0.tar.bz2 \
    https://www.kernel.org/pub/software/scm/git/git-2.9.3.tar.gz \
    ftp://ftp.openssl.org/source/old/1.0.2/openssl-1.0.2g.tar.gz \
    http://prdownloads.sourceforge.net/scons/scons-local-2.3.4.tar.gz \
    https://archive.apache.org/dist/serf/serf-1.3.8.tar.bz2 \
    http://www.sqlite.org/2015/sqlite-amalgamation-3080801.zip \
    http://archive.apache.org/dist/subversion/subversion-1.9.4.tar.bz2 \
    https://www.python.org/ftp/python/3.5.2/Python-3.5.2.tgz \
    https://pypi.python.org/packages/f7/58/bdda9b521a280dea3894d56785fd92aa799ab43d6a7936c39997f6e49ae0/teradata-15.10.0.18.tar.gz
do
    wget "${DL}" -O "${DL##*/}"
    RC=$?
    if [ ${RC} -eq 1 ]
    then
        # If download fails, try without checking the certificate
        # Unfortunately, this is required for some sources
        wget --no-check-certificate "${DL}" -O "${DL##*/}"
        RC=$?
    fi

    if [ $RC -ne 0 ]
    then
        echo "Error downloading package $DL!"
        if [ -z "${ERRORPACKAGES}" ]
        then
            ERRORPACKAGES="${DL##*/}"
        else
            ERRORPACKAGES="${ERRORPACKAGES} ${DL##*/}"
        fi
    fi

done

if [ -z "${ERRORPACKAGES}" ]
then
    echo "Successfully downloaded all packages!"
    exit 0
else
    echo "Error in downloading package(s): ${ERRORPACKAGES}"
    echo "Hint: It turned out, that it is no longer possible to download"
    echo "openssl with the default installation of SLES11SP1 because of"
    echo "SSL issues. In such case, download it manually and copy it over!"
    exit 1
fi
