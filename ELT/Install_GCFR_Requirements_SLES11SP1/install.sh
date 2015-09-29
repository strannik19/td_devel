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
# Installation routine for GCFR required perl modules
#
# Requirements:
# SUSE Linux Enterprise Server 11 Servicepack 1 (SLES11SP1)
#
# Tested on:
#   TDExpress15.00.02_Sles11_40GB (can be downloaded for free)
#
# Installs:
# Perl modules pre-packaged from SUSE (if not present):
#   perl-XML-NamespaceSupport
#   perl-XML-SAX
#   perl-XML-Simple
#   perl-XML-Parser
# Perl modules installed from source:
#   ExtUtils-MakeMaker-7.04.tar.gz
#   DBI-1.634.tar.gz
#   DBD-ODBC-1.52.tar.gz
#   Test-Simple-1.001014.tar.gz
#
###############################################################################
#
# Changing file permissions because somehow, the installation folders don't
# have proper world permissions.
# This is important. Otherwise, no regular user will be able to execute
# GCFR-Perl-Components
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
REQUIRED_RPM_PERL_MODULE="perl-XML-NamespaceSupport perl-XML-Parser perl-XML-SAX perl-XML-Simple"
UNINSTALL_RPM_PERL_MODULE="perl-DBD-ODBC perl-DBI perl-ExtUtils-MakeMaker perl-Test-Simple"

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
# Check version of TTU
# only required for installation of perl modules
#
function check_ttu_version {
    for TTU_VER in 15.00 14.10 14.00 13.10 13.00
    do
        if [ -d "/opt/teradata/client/${TTU_VER}/odbc_64" ]
        then
            INST_ODBC_PATH="/opt/teradata/client/${TTU_VER}/odbc_64/"
            export ODBCINI="/opt/teradata/client/${TTU_VER}/odbc_64/odbc.ini"
            break
        fi
    done

    if [ -z ${INST_ODBC_PATH} ]
    then
        echo -e "Could not find ODBC for Teradata or maybe even TTU!\n"
        exit 3
    else
        echo "Using ODBC in path (${INST_ODBC_PATH})"
    fi
}

#
# Installation routine for perl module
# Argument 1 is the .tar.gz name
# Argument 2 is an optional parameter for the "perl Makefile.pl" command
#
function install_perl_module_from_src {
    PERL_SOFT=$1
    PERL_OPT=$2

    echo -n "Installing package ${PERL_SOFT} ..."
    execute "${PERL_SOFT%-*}" "10.unpack" "tar zxvf ${mydir}/${PERL_SOFT}"
    cd ${PERL_SOFT%.tar.gz}
    execute "${PERL_SOFT%-*}" "20.setown" "chown -R root:root ."
    execute "${PERL_SOFT%-*}" "30.configure" "perl Makefile.PL ${PERL_OPT}"
    execute "${PERL_SOFT%-*}" "40.compile" "make"
    execute "${PERL_SOFT%-*}" "50.install" "make install"
    echo " done"
    cd ..
}

#
# Install all for GCFR required Perl Modules
#
function install_perl_modules {

    for RPM in ${REQUIRED_RPM_PERL_MODULE}
    do
        rpm -q ${RPM} >/dev/null 2>&1
        if [ $? -ne 0 ]
        then
            if [ -r ${mydir}/${RPM}-*.rpm ]
            then
                rpm -U $(ls -1 ${mydir}/${RPM}-*.rpm)
                if [ $? -ne 0 ]
                then
                    echo -e "Fatal Error while installing rpm ${PRM}!\n"
                    exit 31
                fi
            else
                echo -e "Fatal Error. RPM not found: ${PRM}!\n"
            fi
        fi
    done

    for RPM in ${UNINSTALL_RPM_PERL_MODULE}
    do
        rpm -q ${RPM} >/dev/null 2>&1
        if [ $? -eq 0 ]
        then
            rpm -e ${RPM}
            if [ $? -ne 0 ]
            then
                echo "Fatal Error while un-installing rpm ${PRM}!"
                echo "Maybe dependencies to other packages exist ..."
                exit 31
            fi
        fi
    done

    install_perl_module_from_src ExtUtils-MakeMaker-7.04.tar.gz
    install_perl_module_from_src Test-Simple-1.001014.tar.gz
    install_perl_module_from_src DBI-1.634.tar.gz
    install_perl_module_from_src DBD-ODBC-1.52.tar.gz "-o ${INST_ODBC_PATH}"

    # Changing permissions because somehow, the installation folders don't have proper world permissions.
    # This is important. Otherwise, no regular user will be able to execute GCFR-Perl-Components
    find /usr/lib/perl5/site_perl/5.10.0/${myARCHITECTURE}-linux-thread-multi/ -type d -exec chmod o+rx {} \;

}


#
# START here with the processing
#
determine_architecture
check_suse
check_file_integrity
check_ttu_version

#
#
# Start here with extracting tar files, configuring, compiling and installing of source applications
# Installation of RPM packages
# Installation of perl modules via source packages
#
#
mkdir inst.${myinst}
cd inst.${myinst}

install_perl_modules

echo "Teradata GCFR Requirements installed successfully!"
