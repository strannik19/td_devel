#!/bin/bash

#
# Simple install of software packages (TTU patches)
# Only required if using older TTU15 or virtual machine TD Express 15.00.01
# Check versions of software packages for details
#

#
# Check, if executed by user root
#
if [ $(id -un) != "root" ]
then
    echo "Please, run as root!"
    exit 99
fi

for RPM in bteq-15.00.00.03-1.i386.rpm \
           cliv2-15.00.00.04-1.noarch.rpm \
           tdodbc-15.00.00.04-1.noarch.rpm \
           tdwallet1500-15.00.00.02-1.noarch.rpm \
           tptbase1500-15.00.00.04-1.noarch.rpm \
           tptstream1500-15.00.00.04-1.noarch.rpm
do
    rpm -Uvh ${RPM}
    if [ $? -ne 0 ]
    then
        echo "Error installing RPM ${RPM}!" >&2
        exit 1
    fi
done
