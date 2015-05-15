#!/bin/bash

#
# remove all files in HOUSEKEEPINGDIR which are bigger than 1 TB and older than 3 days
# Only one folder possible because multiple folder will unevenly remove files
#    -> One folder get more files removed than the other
#

HOUSEKEEPINGDIR="/srv/nfs4/drive1"

myDATE=$(date +"%Y%m%d-%H%M%S")
myself1=${0##*/}
myself=${myself1%.sh}

logsdir="/root/logs"

# Specify how many versions of own logfiles should be kept
keepownlogs=10

# Define how many kilobytes must be available
minleft=5000000000

if [ ! -d ${HOUSEKEEPINGDIR} ]
then
	echo "Folder ${HOUSEKEEPINGDIR} not found!"
	echo "Folder ${HOUSEKEEPINGDIR} not found!" >&2
	exit 1
fi

{

	cd ${HOUSEKEEPINGDIR}

	mountpoint ${HOUSEKEEPINGDIR} >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		left=$(df | grep ${HOUSEKEEPINGDIR} | awk '{print $4}')
		mountp=${HOUSEKEEPINGDIR}
	else
		mountp=${HOUSEKEEPINGDIR}
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

		echo "Space before housekeeping:"
		df ${mountp}

		echo -e "\nContent of folder ${HOUSEKEEPINGDIR} before housekeeping:"
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

		echo -e "\nContent of folder ${HOUSEKEEPINGDIR} after housekeeping:"
		ls -l

		echo -e "\nSpace after housekeeping:"
	else
		echo "No housekeeping required!!"

		echo -e "\nContent of folder ${HOUSEKEEPINGDIR}:"
		ls -l

		echo -e "\nSpace:"
	fi

	df ${mountp}

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

