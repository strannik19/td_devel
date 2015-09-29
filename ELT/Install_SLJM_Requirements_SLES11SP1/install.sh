#!/bin/bash

##########################################################################
#    install.sh
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


###############################################################################
#
# Installation routine for SLJM Requirements
#
# Requirements:
# SUSE Linux Enterprise Server 11 Servicepack 1 (SLES11SP1)
#
# Tested on:
#   TDExpress15.00.02_Sles11_40GB (can be downloaded for free)
#
# Installs:
# Other packages from SUSE (if not present):
#   tack-5.6-90.55.${myARCHITECTURE}.rpm
#   libncurses6-5.6-90.55.${myARCHITECTURE}.rpm
#   ncurses-devel-5.6-90.55.${myARCHITECTURE}.rpm
#
###############################################################################

myinst=$(date +"%Y%m%d-%H%M%S")
mydir=${PWD}

clear

#
# Check, if executed by user root
#
if [ $(id -un) != "root" ]
then
    echo "Please, run as root!"
    exit 99
fi

ERRORCODE=0


#
# determine processor type base on available RPMs
#
function determine_architecture {
    if [ $(ls -1 | grep "\.rpm$" | awk 'BEGIN {FS="."} {print $(NF-1)}' | sort -u | wc -l) -eq 1 ]
    then
        export myARCHITECTURE=$(ls -1 | grep "\.rpm$" | awk 'BEGIN {FS="."} {print $(NF-1)}' | sort -u)
        echo "Found architecture (processor type) based on available RPMs: ${myARCHITECTURE}"
    else
        echo "Hmm, found RPMs from different processor types." >&2
        echo "Aborting ..." >&2
        exit 11
    fi
}


#
# Execute command with error check and logging
#
function execute {
    PACKAGE=$1
    STEP=$2
    EXE=$3
    if [ -z ${mydir} ]
    then
        echo "Fatal Error. Variable \${mydir} empty. Definitely not proceeding!"
        exit 1
    fi
    echo ${EXE} >${mydir}/inst.${myinst}/${PACKAGE}.${STEP}.log
    eval echo "" | ${EXE} >>${mydir}/inst.${myinst}/${PACKAGE}.${STEP}.log 2>&1
    if [ ${PIPESTATUS[1]} -ne 0 ]
    then
        echo "Error while executing package: ${PACKAGE} -> ${STEP} -> ${EXE}"
        exit ${ERRORCODE}
    fi
    (( ERRORCODE = ERRORCODE + 1 ))
}

#
# Check if supported Linux Distribution and version
#
function check_suse {
    ERROR=0
    if [ -r /etc/SuSE-brand ]
    then
        if [ $(grep -c "^SLES$" /etc/SuSE-brand) -ne 1 ]
        then
            echo "System is SuSE, but not SLES! Continuing could harm your system!"
            while true
            do
                echo -n "Do you want to continue? Not recommended! (y/n) "
                read INPUT
                if [[ "${INPUT}" = "y" || "${INPUT}" = "yes" ]]
                then
                    CONTINUE=y
                    (( ERROR = ERROR + 1 ))
                    break
                elif [[ "${INPUT}" = "n" || "${INPUT}" = "no" ]]
                then
                    CONTINUE=n
                    break

                fi
            done
            if [ "${CONTINUE}" = "n" ]
            then
                echo -e "Installation aborted on user request!\n"
                exit 1
            fi
        fi
        if [ $(grep -c "^VERSION = 11$" /etc/SuSE-release) -ne 1 ]
        then
            echo "System is not SLES11! Continuing could harm your system!"
            while true
            do
                echo -n "Do you want to continue? Not recommended! (y/n) "
                read INPUT
                if [[ "${INPUT}" = "y" || "${INPUT}" = "yes" ]]
                then
                    CONTINUE=y
                    (( ERROR = ERROR + 1 ))
                    break
                elif [[ "${INPUT}" = "n" || "${INPUT}" = "no" ]]
                then
                    CONTINUE=n
                    break

                fi
            done
            if [ "${CONTINUE}" = "n" ]
            then
                echo -e "Installation aborted on user request!\n"
                exit 1
            fi
        fi
        if [ $(grep -c "^PATCHLEVEL = 1$" /etc/SuSE-release) -ne 1 ]
        then
            echo "System is not SLES11SP1! Continuing could harm your system!"
            while true
            do
                echo -n "Do you want to continue? Not recommended! (y/n) "
                read INPUT
                if [[ "${INPUT}" = "y" || "${INPUT}" = "yes" ]]
                then
                    CONTINUE=y
                    (( ERROR = ERROR + 1 ))
                    break
                elif [[ "${INPUT}" = "n" || "${INPUT}" = "no" ]]
                then
                    CONTINUE=n
                    break

                fi
            done
            if [ "${CONTINUE}" = "n" ]
            then
                echo -e "Installation aborted on user request!\n"
                exit 1
            fi
        fi
        if [ ${ERROR} -eq 0 ]
        then
            SUSE="Found supported and tested SuSE Distribution!"
        else
            echo "Untested Linux Distribution found! Continuing with warnings!"
            SUSE="Untested Linux Distribution found! Continuing with warnings!"
        fi
    else
        echo -e "Unsupported Linux Distribution found!\n"
        exit 1
    fi
}

#
# Check integrity (md5sum) of source packages
#
function check_file_integrity {
    if [[ -s md5sum.txt && -r md5sum.txt ]]
    then
        md5sum -c md5sum.txt >/dev/null 2>&1
        if [ $? -eq 0 ]
        then
            echo "Successfully checked consistency of installation packages"
        else
            echo -e "Could not verify integrity of source packages!\n"
            exit 2
        fi
    else
        echo -e "No md5sum.txt file available. Do not check integrity!\n"
    fi
}

#
# START here with the processing
#
determine_architecture
check_suse
check_file_integrity

#
#
# Start here with extracting tar files, configuring, compiling and installing of source applications
# Installation of RPM packages
#
#
mkdir inst.${myinst}
cd inst.${myinst}


echo -n "Installing package tack ..."
if [ $(rpm -qa | grep -c tack) -eq 0 ]
then
    execute "rpm_inst" "10.tack" "rpm -U ${mydir}/tack-5.6-90.55.${myARCHITECTURE}.rpm"
    echo " done"
else
    echo " does not need installation"
fi

echo -n "Installing package libncurses6 ..."
if [ $(rpm -qa | grep -c libncurses6) -eq 0 ]
then
    execute "rpm_inst" "10.libncurses6" "rpm -U ${mydir}/libncurses6-5.6-90.55.${myARCHITECTURE}.rpm"
    echo " done"
else
    echo " does not need installation"
fi

echo -n "Installing package ncurses-devel ..."
if [ $(rpm -qa | grep -c ncurses-devel) -eq 0 ]
then
    execute "rpm_inst" "10.ncurses-devel" "rpm -U ${mydir}/ncurses-devel-5.6-90.55.${myARCHITECTURE}.rpm"
    echo " done"
else
    echo " does not need installation"
fi

echo "Teradata SLJM Requirements installed successfully!"
