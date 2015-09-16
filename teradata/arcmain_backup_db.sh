#!/bin/bash

#
# Small backup script without a lot of preparation
# Goal is to archive a certain database tree given by argument
# Many trees can be executed in sequence: Use more than on argument.
#
# Be aware: arcmain can only backup into regular files (consider space in file system)
#           So if restoring, the zip file need to get unzipped first
#           Restore capability will be added later
#

#
# Log directory will be created in current folder
# Datadir will be created if it doesn't exist
#

#
# Error Code description:
#    1 = No argument given (at least one is required to know the database tree to export)
#    2 = Errors occurred at some database archives, please check (arcmain or gzip)
#        While using more than one arguments, at least one can be successful were the other is not
#        But continuing anyway, if others will work
#    3 = 
#  Starting from here, errors have caused immediate exit
#    21 = Failed to create data directory (as it was not created before)
#    22 = The data directory exists, but is not a directory
#    23 = Data directory exists, but is not writeable
#    24 = Failed to create log directory (as it was not created before)
#    25 = The log direcotry exists, but is not a directory
#    26 = Log directory exists, but is not writeable
#    27 = Remaining arcmain ARCHIVE file still present
#
# Also, writing the stderr channel to a file will help to find them in the long standard output
#

# pipefail: the return value of a pipeline is the status of the last command to exit
# with a non-zero status, or zero if no command exited with a non-zero status
set -o pipefail

if [ "$1" = "" ]
then
    echo "Argument database missing!" >&1
    exit 1
fi

#
# START change as required
#
export TDPID=dbc
export DATADIR="/root/backup"
export TD_USERNAME="dbc"
export TD_PASSWORD="dbc"
export ARCMAINSESSIONS=4
export COMPRESSOR="gzip"
export COMPRESSOR_EXT="gzip"
#
# END change as required
# remember, restore must be done with same number of sessions as backup
#

#
# Some default settings
# Can be changed, but with caution
#
export BACKUPDATE=$(date +"%Y-%m-%d")

# using this ugly file for arcmain, because it only supports file names not longer than 8 bytes
ARCH="ARC$$"

#
# Initialization of variables
#
ERRORS=0
ARCMAINERRORS=0
COMPRESSORERRORS=0
SUCCESSFUL=0

#
# End of variable setting
#

# Double output for arcmain file to link it to log files (especially for individual log files)
# The arcmain file name is also in logfile of arcmain, but otherwise not seen on stdout or stderr channels
echo "Starting database archives to arcmain file: ${ARCH}"
echo "Starting database archives to arcmain file: ${ARCH}" >&2

#
# Define helper functions
#
function report_error_stats {
    if [ ${ARCMAINERRORS} -eq 1 ]
    then
        echo "One arcmain error!"
    elif [ ${ARCMAINERRORS} -gt 1 ]
    then
        echo "${ARCMAINERRORS} arcmain errors!"
    fi
    if [ ${COMPRESSORERRORS} -eq 1 ]
    then
        echo "One ${COMPRESSOR%% *} error!"
    elif [ ${COMPRESSORERRORS} -gt 1 ]
    then
        echo "${COMPRESSORERRORS} ${COMPRESSOR%% *} errors!"
    fi
}

function exit_routine {

    # if I want explicitly to exit with a certain errorcode
    # and should have a errormessage already printed
    if [ "${EXITVAR}" != "" ]
    then
        exit ${EXITVAR}
    fi

    # If script comes to its end regularly, check was has happened
    if [[ ${ERRORS} -gt 0 && ${SUCCESSFUL} -eq 0 ]]
    then
        echo "Errors occurred, no successful backup. Please check log files!"
        report_error_stats
        exit 2
    elif [[ ${ERRORS} -gt 0 && ${SUCCESSFUL} -eq 1 ]]
    then
        echo "Errors occurred, and one successful backup. Please check log files!"
        report_error_stats
        exit 3
    elif [[ ${ERRORS} -gt 0 && ${SUCCESSFUL} -gt 1 ]]
    then
        echo "Errors occurred, and ${SUCCESSFUL} successful backups. Please check log files!"
        report_error_stats
        exit 3
    elif [[ ${ERRORS} -eq 0 && ${SUCCESSFUL} -eq 1 ]]
    then
        echo "No Error occurred, and one successful backup!"
        exit 0
    elif [[ ${ERRORS} -eq 0 && ${SUCCESSFUL} -gt 1 ]]
    then
        echo "No Error occurred, and ${SUCCESSFUL} successful backups!"
        exit 0
    fi
}
#
# End function definition
#

trap "exit_routine" EXIT

if [ ! -e "${DATADIR%/}" ]
then
    echo "Creating data directory" >&2
    mkdir "${DATADIR%/}" >&2
    if [ $? -ne 0 ]
    then
        echo "Error: ${DATADIR%/} could not be created!" >&2
        EXITVAR=21
        exit
    else
        echo "Creating data directory successful" >&2
    fi
elif [ ! -d "${DATADIR%/}" ]
then
    echo "Error: ${DATADIR%/} exists but is not a directory!" >&2
    EXITVAR=22
    exit
elif [ ! -w "${DATADIR%/}" ]
then
    echo "Error: ${DATADIR%/} is not writeable!" >&2
    EXITVAR=23
    exit
fi

if [ ! -e log ]
then
    echo "Creating log directory" >&2
    mkdir log >&2
    if [ $? -ne 0 ]
    then
        echo "Error: ${DATADIR%/} could not be created!" >&2
        EXITVAR=24
        exit
    else
        echo "Creating log directory successful" >&2
    fi
elif [ ! -d log ]
then
    echo "Error: log exists but is not a directory!" >&2
    EXITVAR=25
    exit
elif [ ! -w log ]
then
    echo "Error: log is not writeable!" >&2
    EXITVAR=26
    exit
fi

#
# Main block
# loop over all arguments as database(tree) to be archived
#
for DB in $*
do

    if [ -e "${ARCH}" ]
    then
        # Should usually not happen, because every new execution will have a new name
        # But part of file name is Linux processid, and it will repeat
        # Check for every new start, if there are any leftovers within same run
        echo "Backup Error ${DB}: ${ARCH} already exists!" >&2
        if [ ${ERRORS} -eq 0 ]
        then
            # if no error has occurred so far, exit with 27
            EXITVAR=27
            exit
        else
            # 
            EXITVAR=2
            exit
        fi
    fi

    export COMPRESSEDFILE="${DATADIR%/}/${DB}.${BACKUPDATE}.Sessions${ARCMAINSESSIONS}.dmp.gz"
    export ARCMAINLOGFILE="log/arcmain.${DB}.${BACKUPDATE}.Sessions${ARCMAINSESSIONS}.log"

    #
    # Start arcmain here to archive into regular file
    #
    if [ -f "${ARCMAINLOGFILE}" ]
    then
        # move to different name, if one exists already for this day
        DATE=$(ls -l --time-style=long-iso "${ARCMAINLOGFILE}" | awk 'BEGIN {OFS=""} {print $6, ".", $7}')
        mv "${ARCMAINLOGFILE}" "${ARCMAINLOGFILE}.${DATE}.bak"
    fi

    {
        echo "LOGON ${TD_USERNAME},${TD_PASSWORD};"
        echo "ARCHIVE DATA TABLES"
        echo "(${DB}) ALL"
        echo ",RELEASE LOCK"
        echo ",FILE=${ARCH};"
        echo "LOGOFF;"
    } | arcmain sessions=${ARCMAINSESSIONS} outlog="${ARCMAINLOGFILE}"

    RC=$?

    if [ ${RC} -ne 0 ]
    then
        echo "Backup Error ${DB}: arcmain failed with error ${RC}" >&2
        (( ERRORS = ERRORS + 1 ))
        (( ARCMAINERRORS = ARCMAINERRORS + 1 ))
        continue
    fi

    # handling the annoying RESTARTLOG files of arcmain
    RESTARTLOG=$(awk '/RESTARTLOG =/ {print $5}' "${ARCMAINLOGFILE}")
    if [ "${RESTARTLOG}" != "" ]
    then
        rm -f "${RESTARTLOG}" >/dev/null 2>&1
    fi

    #
    # Start the compress on existing file
    #
    if [ -f "${COMPRESSEDFILE}" ]
    then
        # move to different name, if one exists already for this day
        DATE=$(ls -l --time-style=long-iso "${COMPRESSEDFILE}" | awk 'BEGIN {OFS=""} {print $6, ".", $7}')
        mv "${COMPRESSEDFILE}" "${COMPRESSEDFILE}.${DATE}.bak"
    fi

    ${COMPRESSOR} -c <${ARCH} >"${COMPRESSEDFILE}"
    RC=$?

    if [ ${RC} -ne 0 ]
    then
        echo "Backup Error ${DB}: ${COMPRESSOR%% *} failed with error ${RC}!" >&2
        (( ERRORS = ERRORS + 1 ))
        (( COMPRESSORERRORS = COMPRESSORERRORS + 1 ))
    else
        rm ${ARCH}
    fi

    (( SUCCESSFUL = SUCCESSFUL + 1 ))
done

exit 0
