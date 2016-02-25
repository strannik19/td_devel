#!/usr/bin/env bash

##########################################################################
#    to_be_executed_in_guest.sh
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

#
# This script is for installing TD developers package from
# GitHub/tdawen
#

x=${0##*/}
mySelf=${x%.*}

# for development only
rm -rf td_devel_inst_tmp >/dev/null 2>&1

mkdir td_devel_inst_tmp
cd td_devel_inst_tmp

# save current folder for log files
logFolder=${PWD}

CommandStep=0

function Exec() {
    (( CommandStep = CommandStep + 1 ))
    echo -n "Run cmd: ${1} ..."
    eval $1 >${logFolder}/${mySelf}.Step${CommandStep}.log 2>&1
    if [ $? -ne 0 ]
    then
        echo " fail (check ${logFolder}/${mySelf}.Step${CommandStep}.log)"
        exit 1
    else
        echo " done"
    fi
}

Exec "wget -O td_devel-master.zip https://github.com/tdawen/td_devel/archive/master.zip"

Exec "unzip td_devel-master.zip"

Exec "cd td_devel-master/ELT/Install_TD_Developers_Package_SLES11SP1"

Exec "bash download.sh"

Exec "bash install.sh"
