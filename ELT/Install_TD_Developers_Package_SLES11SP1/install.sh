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
# Installation routine for version control software: Subversion and Git
#   and the requirements for both
#
# Requirements:
# SUSE Linux Enterprise Server 11 Servicepack 1 (SLES11SP1)
#
# Tested on:
#   TDExpress15.00.02_Sles11_40GB (can be downloaded for free)
#
# Installs:
# Required Development applications (under /usr/local):
#   openssl-1.0.2d.tar.gz
#   apr-1.5.2.tar.bz2
#   apr-util-1.5.4.tar.bz2
#   scons-local-2.3.4.tar.gz (required only by serf-1.3.8.tar.bz2)
#   serf-1.3.8.tar.bz2
#   subversion-1.9.2.tar.bz2 (including sqlite-amalgamation-3080801.zip)
#   curl-7.40.0.tar.bz2
#   git-2.6.3.tar.gz
#
###############################################################################
#
# Tested: svn via ssh, https, http protocols
#       : git via ssh, https, http protocols
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
check_suse
check_file_integrity

#
#
# Start here with extracting tar files, configuring, compiling and installing of source applications
#
#
mkdir inst.${myinst}
cd inst.${myinst}


echo -n "Installing package openssl ..."
execute "openssl" "10.unpack" "tar zxvf ${mydir}/openssl-1.0.2d.tar.gz"
cd openssl-1.0.2d
execute "openssl" "20.setown" "chown -R root:root ."
execute "openssl" "30.configure" "./config -shared"
execute "openssl" "40.compile" "make"
execute "openssl" "50.install" "make install"
execute "openssl" "60.copycerts" "cp -pRv /etc/ssl/certs/* /usr/local/ssl/certs"
echo " done"
cd ..


echo -n "Installing package apr ..."
execute "apr" "10.unpack" "tar jxvf ${mydir}/apr-1.5.2.tar.bz2"
cd apr-1.5.2
execute "apr" "20.setown" "chown -R root:root ."
execute "apr" "30.configure" "./configure"
execute "apr" "40.compile" "make"
execute "apr" "50.install" "make install"
echo " done"
cd ..


echo -n "Installing package apr-util ..."
execute "apr-util" "10.unpack" "tar jxvf ${mydir}/apr-util-1.5.4.tar.bz2"
cd apr-util-1.5.4
execute "apr-util" "20.setown" "chown -R root:root ."
execute "apr-util" "30.configure" "./configure --with-apr=/usr/local/apr"
execute "apr-util" "40.compile" "make"
execute "apr-util" "50.install" "make install"
echo " done"
cd ..


echo -n "Installing package scons ..."
execute "scons" "01.mkdir" "mkdir scons"
cd scons
execute "scons" "10.unpack" "tar zxvf ${mydir}/scons-local-2.3.4.tar.gz"
execute "scons" "20.setown" "chown -R root:root ."
if [ ! -d ${HOME}/bin ]
then
    mkdir ${HOME}/bin
fi
if [ $(echo ${PATH} | grep -c ${HOME}/bin) -eq 0 ]
then
    PATH=${PATH}:${HOME}/bin
fi
scons_pwd=${PWD}
cd $HOME/bin
execute "scons" "12.rm_ln" "rm -f scons"
execute "scons" "13.create_ln" "ln -s ${scons_pwd}/scons.py scons"
echo " done"
cd ${mydir}/inst.${myinst}


echo -n "Installing package serf ..."
execute "serf" "10.unpack" "tar jxvf ${mydir}/serf-1.3.8.tar.bz2"
cd serf-1.3.8
execute "serf" "20.setown" "chown -R root:root ."
execute "serf" "40.compile" "scons APR=/usr/local/apr/ APU=/usr/local/apr OPENSSL=/usr/local/ssl"
execute "serf" "50.install" "scons install"
echo " done"
cd ..


echo -n "Installing package subversion ..."
execute "subversion" "10.unpack" "tar jxvf ${mydir}/subversion-1.9.2.tar.bz2"
execute "subversion" "11.unzipsqlite" "unzip -x ${mydir}/sqlite-amalgamation-3080801.zip"
execute "subversion" "12.mvsqlite" "mv sqlite-amalgamation-3080801 subversion-1.9.2/sqlite-amalgamation"
cd subversion-1.9.2
execute "subversion" "20.setown" "chown -R root:root ."
execute "subversion" "30.configure" "./configure --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr --with-serf=/usr/local"
execute "subversion" "40.compile" "make"
execute "subversion" "50.install" "make install"
echo " done"
cd ..


echo -n "Installing package curl ..."
execute "curl" "10.unpack" "tar jxvf ${mydir}/curl-7.40.0.tar.bz2"
cd curl-7.40.0
execute "curl" "20.setown" "chown -R root:root ."
execute "curl" "21.copycert" "cp -p ${mydir}/certGithub.pem /usr/local/ssl/certs"
#execute "curl" "30.configure" "./configure --with-ssl=/usr/local/ssl --with-http --with-ftp --with-telnet"
execute "curl" "30.configure" "./configure --with-ssl=/usr/local/ssl --with-http --with-ftp --with-telnet --with-ca-bundle=/usr/local/ssl/certs/certGithub.pem"
execute "curl" "40.compile" "make"
execute "curl" "50.install" "make install"
echo " done"
cd ..


echo -n "Installing package git ..."
execute "git" "10.unpack" "tar zxvf ${mydir}/git-2.6.3.tar.gz"
cd git-2.6.3
execute "git" "20.setown" "chown -R root:root ."
execute "git" "30.configure" "./configure --with-curl=/usr/local"
execute "git" "40.compile" "make"
execute "git" "50.install" "make install"
echo " done"
cd ..

echo "Teradata Developer's Package installed successfully!"
