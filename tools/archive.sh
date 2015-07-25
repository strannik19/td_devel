#!/bin/bash

##########################################################################
#    archive.sh
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
# Compress big files with pigz (parallel gzip compressor)
#

# enter multipe folders seperated by blanks in here
ARCHIVEDIRS="/srv/nfs4/drive1"

myDATE=$(date +"%Y%m%d-%H%M%S")
myself1=${0##*/}
myself=${myself1%.sh}

logsdir="/root/logs"

# Specify how many versions of own logfiles should be kept
keepownlogs=10

{

	if [[ $(type pigz >/dev/null 2>&1) != 0 ]]
	then
		compressor="pigz"
	elif [[ $(type gzip >/dev/null 2>&1) != 0 ]]
	then
		compressor="gzip"
	else
		echo "Error: no compressor found!"
		exit 2
	fi

	for ARCHIVEDIR in ${ARCHIVEDIRS}
	do

		if [ ! -d ${ARCHIVEDIR} ]
		then
			echo "Folder ${ARCHIVEDIR} not found!"
		fi

		cd ${ARCHIVEDIR}

		if [ $(find . -type f -size +1G \( ! -name \*.gz \) | wc -l) -gt 0 ]
		then
			echo "Content of folder ${ARCHIVEDIR} before archiving:"
			ls -l
			echo -e "\nCompressing file(s):"

			for FI in $(find . -type f -size +1G \( ! -name \*.gz \) | sort)
			do
				ls -l ${FI}
				${compressor} ${FI}
			done

			echo -e "\nContent of folder ${ARCHIVEDIR} after archiving:"
			ls -l
		else
			echo "No files available for archiving"
			echo "Content of folder ${ARCHIVEDIR}:"
			ls -l
		fi

		echo -e "\n==============================================================================================\n"

	done

	#
	# Housekeeping of log files
	#
	cd ${logsdir}

	logs=$(ls -1 ${myself}.*.log | wc -l)
	if [ ${logs} -gt ${keepownlogs} ]
	then
		echo -e "\nRemoving older log file(s):"
		(( rmlogs = logs - keepownlogs ))
		for FI in $(ls -1 ${myself}.*.log | head -${rmlogs})
		do
			echo rm -f ${FI}
		done
	fi

} >${logsdir}/${myself}.${myDATE}.log 2>&1

