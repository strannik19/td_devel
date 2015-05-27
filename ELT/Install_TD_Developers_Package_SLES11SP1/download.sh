#!/bin/bash

#
# Download required free packages
#

ERRORPACKAGES=""

for DL in \
	http://ftp.fau.de/apache/apr/apr-1.5.2.tar.bz2 \
	http://ftp.fau.de/apache/apr/apr-util-1.5.4.tar.bz2 \
	http://curl.haxx.se/download/curl-7.40.0.tar.bz2 \
	https://cpan.metacpan.org/authors/id/M/MJ/MJEVANS/DBD-ODBC-1.52.tar.gz \
	https://cpan.metacpan.org/authors/id/T/TI/TIMB/DBI-1.633.tar.gz \
	https://cpan.metacpan.org/authors/id/B/BI/BINGOS/ExtUtils-MakeMaker-7.04.tar.gz \
	https://www.kernel.org/pub/software/scm/git/git-2.4.2.tar.gz \
	https://www.openssl.org/source/openssl-1.0.2a.tar.gz \
	http://prdownloads.sourceforge.net/scons/scons-local-2.3.4.tar.gz \
	http://serf.googlecode.com/svn/src_releases/serf-1.3.8.tar.bz2 \
	http://www.sqlite.org/2015/sqlite-amalgamation-3080801.zip \
	http://mirror.synyx.de/apache/subversion/subversion-1.8.13.tar.bz2 \
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
