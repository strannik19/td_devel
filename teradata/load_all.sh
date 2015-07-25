#!/bin/bash

##########################################################################
#    analyze_datafile.pl
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


export PARA=3
export GAP=10

{
	for FI in tpt/*/*.tpt
	do
		if [ -f STOP ]
		then
			while [ -f tmp/RUNNING.* ]
			do
				sleep 30
			done
			rm STOP
			ts=$(date +"%Y-%m-%d %H:%M:%S")
			printf "[%s][%-6s][%10s][%-61s] %s\n" "${ts}" "END" "" "" "Process stopped by user intervention"
			exit 99
		fi

		if [ -f PAUSE ]
		then
			while [ -f PAUSE ]
			do
				sleep 30
			done
		fi

		x=${FI##*/}
		export TRG=${x%.tpt}
		export SRC=${TRG#DINIT_}

		if [ ! -f done/${TRG%.*}/"${TRG}" ]
		then

			while true
			do
				sleep ${GAP}

				if [ -f STOP ]
				then
					rm STOP
					ts=$(date +"%Y-%m-%d %H:%M:%S")
					printf "[%s][%-6s][%10s][%-61s] %s\n" "${ts}" "END" "" "" "Process stopped by user intervention"
					exit 99
				fi

				if [ -f PAUSE ]
				then
					printf "[%s][%-6s][%10s][%-61s] %s\n" "${ts}" "PAUSE" "" "" "Process paused by user intervention"
					while [ -f PAUSE ]
					do
						sleep 30
					done
				fi

				[ $(ls -1 tmp/RUNNING.* 2>/dev/null | wc -l) -lt ${PARA} ] && break
			done

			./load_parallel.sh &

		else
			ts=$(date +"%Y-%m-%d %H:%M:%S")
			printf "[%s][%-6s][%10s][%-61s] %s\n" "${ts}" "Skip" "" "${TRG}" "Already processed"
		fi

	done
} | tee -i log/load_all.log
