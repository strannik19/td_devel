#!/bin/bash

###############################################################################
#
# Installation routine for GCFR and required perl modules
# (c) 2015 Teradata Corp, Andreas Wenzel
#
# Requirements:
# SUSE Linux Enterprise Server 11 Servicepack 1 (SLES11SP1)
#
# Tested on:
#   TDExpress14.10_Sles11_40GB (can be downloaded for free)
#   TDExpress15.00.01_Sles11_40GB (can be downloaded for free)
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
#
# Modifies if required:
#   /etc/hosts    -> to add hostname "tddemo" and "tddemocop1" to 127.0.0.1
#   odbc.ini      -> in TTU install folder add DSN for "tddemo"
# If modified, backup files can be found in original location with timestamp
# of the change. Eg. /etc/hosts.20150611-091915
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
export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/ssl/lib:${LD_LIBRARY_PATH}
export LD_RUN_PATH=/usr/local/lib:/usr/local/ssl/lib


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
        echo " failed. No installation folder found!" >&2
        exit 1
    fi
    echo ${EXE} >${mydir}/inst.${myinst}/${PACKAGE}.${STEP}.log
    echo "" | ${EXE} 2>&1 >${mydir}/inst.${myinst}/${PACKAGE}.${STEP}.log; RC=${PIPESTATUS[1]}
    if [ $RC -ne 0 ]
    then
        echo " failed. Please check log file ${mydir}/inst.${myinst}/${PACKAGE}.${STEP}.log" >&2
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
# Check version of TTU
# only required for installation of perl modules
#
function check_ttu_version {
    for TTU_VER in 15.00 14.10 14.00
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

    echo -n "Installing Perl Module ${PERL_SOFT} from source ..." >&2
    execute "${PERL_SOFT%-*}" "10.unpack" "tar zxvf ${mydir}/${PERL_SOFT}"
    cd ${PERL_SOFT%.tar.gz}
    if [ $? -ne 0 ]
    then
        echo " failed! Cannot change into unpacked directory!" >&2
        return 1
    fi
    execute "${PERL_SOFT%-*}" "20.setown" "chown -R root:root ."
    execute "${PERL_SOFT%-*}" "30.configure" "perl Makefile.PL ${PERL_OPT}"
    execute "${PERL_SOFT%-*}" "40.compile" "make"
    execute "${PERL_SOFT%-*}" "50.install" "make install"
    echo " done!" >&2
    cd ..
}

#
# Install all for GCFR required Perl Modules
#
function install_perl_modules {

    for RPM in ${UNINSTALL_RPM_PERL_MODULE}
    do
        echo -n "Uninstalling Perl module ${RPM} ..." >&2
        rpm -q ${RPM} >/dev/null 2>&1
        if [ $? -ne 0 ]
        then
            rpm -e ${RPM}
            if [ $? -ne 0 ]
            then
                echo " failed!" >&2
                echo "Fatal Error while un-installing rpm ${PRM}!"
                echo "Maybe dependencies to other packages exist ..."
                exit 31
            else
                echo " done" >&2
            fi
        else
            echo " done. Nothing to uninstall" >&2
        fi
    done

    for RPM in ${REQUIRED_RPM_PERL_MODULE}
    do
        echo -n "Installing Perl module ${RPM} ..." >&2
        rpm -q ${RPM} >/dev/null 2>&1
        if [ $? -ne 0 ]
        then
            if [ -r ${mydir}/${RPM}-*.rpm ]
            then
                rpm -U $(ls -1 ${mydir}/${RPM}-*.rpm)
                if [ $? -ne 0 ]
                then
                    echo " failed!" >&2
                    echo -e "Fatal Error while installing rpm ${PRM}!\n"
                    exit 31
                else
                    echo " done" >&2
                fi
            else
                echo " failed. RPM file not found!" >&2
                echo -e "Fatal Error. RPM not found: ${PRM}!\n"
            fi
        else
            echo " done. Already installed!" >&2
        fi
    done

    install_perl_module_from_src ExtUtils-MakeMaker-7.04.tar.gz >/dev/null
    install_perl_module_from_src Test-Simple-1.001014.tar.gz >/dev/null
    install_perl_module_from_src DBI-1.634.tar.gz >/dev/null
    install_perl_module_from_src DBD-ODBC-1.52.tar.gz "-o ${INST_ODBC_PATH}" >/dev/null

    # Changing permissions because somehow, the installation folders don't have proper world permissions.
    # This is important. Otherwise, no regular user will be able to execute GCFR-Perl-Components
    find /usr/lib/perl5/site_perl/5.10.0/x86_64-linux-thread-multi/ -type d -exec chmod o+rx {} \;

}


#
# Preparing odbc.ini in TTU folder
#
function prepare_odbc_ini {
    echo -n "Preparing ${ODBCINI} ..." >&2
    if [ -e ${ODBCINI} ]
    then
        # odbc.ini exists in expected folder
        if [[ -w ${ODBCINI} && -f ${ODBCINI} ]]
        then
            # odbc.ini is writeable and a regular file
            if [ $(grep -c "^\[tddemo\]" ${ODBCINI}) -ne 0 ]
            then
                # Entry for "tddemo" already exists in odbc.ini
                echo " done. Nothing changed because already as expected!" >&2
            else
                {
                    echo -e "\n[tddemo]"
                    echo "Driver=${INST_ODBC_PATH%%/}/lib/tdata.so"
                    echo "Description=Teradata database"
                    echo "DBCName=tddemo"
                    echo "LastUser="
                    echo "Username="
                    echo "Password="
                    echo "Database="
                    echo "DefaultDatabase="
                    echo "OutputAsResultSet=Yes"
                } >> ${ODBCINI}
                mv ${ODBCINI} ${ODBCINI}.${myinst}
                awk 'BEGIN {a=0; FS="="}
                    {
                        if ($0 == "[ODBC Data Sources]") {
                            print;
                            a = 1;
                        } else if ($1 == "tddemo" && a == 1) {
                            print;
                            a = 2;
                        } else if ($0 == "" && a == 1) {
                            print "tddemo=tdata.so\n"
                            a = 3;
                        } else {
                            print;
                        }
                    }' <${ODBCINI}.${myinst} >${ODBCINI}
                echo " done!" >&2
            fi
        else
            echo " failed. File odbc.ini exists, but not writeable!" >&2
            exit 1
        fi
    else
        echo " failed. File odbc.ini does not exist. Please check TTU installation!" >&2
        exit 1
    fi
}

#
# Preparing /etc/hosts file
#
function prepare_etc_hosts {
    echo -n "Preparing /etc/hosts file ..." >&2
    if [ -e /etc/hosts ]
    then
        # /etc/hosts file exists
        if [[ -w /etc/hosts && -f /etc/hosts ]]
        then
            # /etc/hosts is writeable and a regular file
            if [ $(egrep -c "^127\.0\.0\.1.+tddemo" /etc/hosts) -ne 0 ]
            then
                # Entry for "tddemo" already exists in /etc/hosts
                echo " done. Nothing changed because already as expected!" >&2
            else
                mv /etc/hosts /etc/hosts.${myinst}
                awk '/^127\.0\.0\.1/ {print $0, "tddemocop1 tddemo"; next;} {print}' </etc/hosts.${myinst} >/etc/hosts
                if [ $(egrep -c "^127\.0\.0\.1" /etc/hosts) -eq 0 ]
                then
                    # host entry for 127.0.0.1 not found, add it to file
                    echo "127.0.0.1       localhost dbccop1 tddemocop1 tddemo" >>/etc/hosts
                fi
                echo " done!" >&2
            fi
        else
            echo " failed. File /etc/hosts exists, but not writeable!" >&2
            exit 1
        fi
    else
        echo " failed. File /etc/hosts does not exist!" >&2
        exit 1
    fi
}


#
# Check, if the /etc/profile needs to be fixed (required eg. for TD Express 15.00.01)
#
function check_etc_profile {
    if [ $(grep -c "^ODBCINI" /etc/profile) -gt 0 ]
    then
        echo "/etc/profile need to get fixed because of ODBCINI variable error"
    fi
}


#
# Fix /etc/profile because incorrect set ODBCINI variable
#
function fix_etc_profile {
    if [ $(grep -c "^ODBCINI" /etc/profile) -gt 0 ]
    then
        cp -p /etc/profile /etc/profile.${myinst}
        grep -v "^ODBCINI" /etc/profile.${myinst} >/etc/profile
    fi
}


#
# START here with the processing
# Check version of SUSE distribution
# Check version of installed TTU
# Check if /etc/profile needs fix
#
check_suse
check_ttu_version
check_etc_profile

#
#
# Start here with doing all that required stuff
# comment it if you don't like to do that
# like extracting tar files, configuring, compiling and installing of source applications
# De-/Installation of RPM packages
# Installation of perl modules via source packages
#
#
mkdir inst.${myinst}
cd inst.${myinst}

install_perl_modules
prepare_odbc_ini
prepare_etc_hosts
fix_etc_profile

echo "Required Perl Modules successfully installed!"
echo "Command for odbc.ini: \"export ODBCINI=\"${ODBCINI}\""

exit 0
