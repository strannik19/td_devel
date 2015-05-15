#!/bin/bash

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

