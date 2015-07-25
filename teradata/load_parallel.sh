#!/bin/bash

##########################################################################
#    load_parallel.sh
#    Copyright (C) 2015  Andreas Wenzel (https://github.com/awenny)
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


#trap "echo RAUS" EXI

touch tmp/RUNNING.${TRG}

ts=$(date +"%Y-%m-%d %H:%M:%S")
printf "[%s][%-6s][%10s][%-61s]\n" "${ts}" "Start" "" "${TRG}"

./load.sh "${SRC}" "${TRG}"

if [ -f log/${TRG%.*}/tpt.${TRG}.log ]
then
	if [ $(grep -c "Job .* completed successfully" log/${TRG%.*}/tpt.${TRG}.log) -eq 0 ]
	then
		ts=$(date +"%Y-%m-%d %H:%M:%S")
		printf "[%s][%-6s][%10s][%-61s]\n" "${ts}" "Done" "" "${TRG}"
	else
		rowcnt=$(awk '/Total Rows Applied/ {print $5}' log/${TRG%.*}/tpt.${TRG}.log)
		ts=$(date +"%Y-%m-%d %H:%M:%S")
		printf "[%s][%-6s][%10d][%-61s]\n" "${ts}" "Done" $rowcnt "${TRG}"
		echo $rowcnt >done/${TRG%.*}/"${TRG}"
	fi
else
	ts=$(date +"%Y-%m-%d %H:%M:%S")
	printf "[%s][%-6s][%10s][%-61s] %s\n" "${ts}" "WARN" "" "${TRG}" "No Logfile found"
fi

rm tmp/RUNNING.${TRG}

exit
