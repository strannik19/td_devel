#!/bin/bash

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
	https://cpan.metacpan.org/authors/id/M/MJ/MJEVANS/DBD-ODBC-1.52.tar.gz \
	https://cpan.metacpan.org/authors/id/T/TI/TIMB/DBI-1.634.tar.gz \
	https://cpan.metacpan.org/authors/id/B/BI/BINGOS/ExtUtils-MakeMaker-7.04.tar.gz \
	http://search.cpan.org/CPAN/authors/id/E/EX/EXODIST/Test-Simple-1.001014.tar.gz
do
	if [ "${DL#https://cpan.metacpan.org}" = "${DL}" ]
	then
		wget "${DL}" -O "${DL##*/}"
	else
		wget --no-check-certificate "${DL}" -O "${DL##*/}"
	fi

	if [ $? -ne 0 ]
	then

		echo "Error downloading package $DL!"
		if [ -z "${ERRORPACKAGES}" ]
		then
			ERRORPACKAGES="${DL##*/}"
		else
			ERRORPACKAGES="${ERRORPACKAGES} ${DL##*/}"
		fi

	else
		md5sum "${DL##*/}" >> md5sum.txt
	fi

done

if [ -z "${ERRORPACKAGES}" ]
then
	echo "Successfully downloaded all packages!"
	exit 0
else
	echo "Error in downloading package(s): ${ERRORPACKAGES}"
	exit 1
fi
