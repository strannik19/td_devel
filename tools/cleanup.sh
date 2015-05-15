#!/bin/bash

#
# remove all gz files in CLEANUPDIR until a certain space is freed up again
# Only one folder possible because multiple folder will unevenly remove files
#    -> One folder get more files removed than the other
#

CLEANUPDIR="/srv/nfs4/drive1"

myDATE=$(date +"%Y%m%d-%H%M%S")
myself1=${0##*/}
myself=${myself1%.sh}

logsdir="/root/logs"

# Specify how many versions of own logfiles should be kept
keepownlogs=10

# Define how many kilobytes must be available on the filesystem
minleft=5000000000

if [ ! -d ${CLEANUPDIR} ]
then
	echo "Folder ${CLEANUPDIR} not found!"
	echo "Folder ${CLEANUPDIR} not found!" >&2
	exit 1
fi

{

	cd ${CLEANUPDIR}

	mountpoint ${CLEANUPDIR} >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		left=$(df | grep ${CLEANUPDIR} | awk '{print $4}')
		mountp=${CLEANUPDIR}
	else
		mountp=${CLEANUPDIR}
		while true
		do
			mountp1=${mountp%/*}
			mountp=${mountp1}
			echo $mountp
			mountpoint ${mountp} >/dev/null 2>&1
			if [ $? -eq 0 ]
			then
				break
			fi
		done
		left=$(df | grep ${mountp} | awk '{print $4}')
	fi

	if [ $left -lt $minleft ]
	then

		echo "Space before cleanup:"
		df ${mountp}

		echo -e "\nContent of folder ${CLEANUPDIR} before cleanup:"
		ls -l

		echo -e "\nDeleting file(s):"

		for FI in $(ls -1rt | grep "\.gz$")
		do
			ls -l ${FI}
			rm -f ${FI}
			# Check, if enough space has been freed
			newleft=$(df | grep ${mountp} | awk '{print $4}')
			if [ $newleft -gt $minleft ]
			then
				break
			fi
		done

		echo -e "\nContent of folder ${CLEANUPDIR} after cleanup:"
		ls -l

		echo -e "\nSpace after cleanup:"
	else
		echo "No cleanup required!!"

		echo -e "\nContent of folder ${CLEANUPDIR}:"
		ls -l

		echo -e "\nSpace:"
	fi

	df ${mountp}

	#
	# Cleanup of log files
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

