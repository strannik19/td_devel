#!/bin/bash

# This script is for resetting an aborted GCFR Training Lab run back to start
# It requires everything prepared:
#   Existing GCFR database installation which will be dropped before recreation
#   Existing GCFR ELT installation under /GCFR_Root
#   Existing folder structure:
#     /GCFR_Root                     => where the ETL component is installed
#     $HOME/2_GCFR_Standard_Packages => the DDL package is already unzipped
#                                       and prepared (logon, Token_repalcement_values.txt)
#     $HOME/4_Objects_For_Exercises  => the folder from Training Lab

# Check if start step specified
if [ -z "$1" ]
then
   StartStep=1
else
   StartStep="$1"
fi

# Check if end step specified
if [ -z "$2" ]
then
   EndStep=9999
else
   EndStep="$2"
fi

export mylog="${HOME}/reset_Training_Lab.log"

rm -f ${mylog}

Step=1
if [ $Step -ge $StartStep ] && [ $Step -le $EndStep ]
then
    echo -n "Step 1: Starting preparation input data, logs and scripts ..."
    echo -e "\n################################################################################################## Starting prepare folders" >>${mylog}
    {
        cd /GCFR_Root
        rm {logs,logon}/*
        rm scripts/[A-Z]*
        rm export_data/archive/*
        rm export_data/[A-Z]*

        cd source_data
        mv customer/{archive,loading}/CUSTOMER_* customer
        rm customer/{archive,loading}/*
        mv accounts/{archive,loading}/ACCOUNTS_* accounts
        rm accounts/{archive,loading}/*
        mv transactions/{archive,loading}/TRANSACTIONS_* transactions/
        rm transactions/{archive,loading}/*
        rm -f /opt/teradata/client/15.00/tbuild/{checkpoint,logs}/*
    } >>${mylog} 2>&1
    echo " done"
fi


Step=2
if [ $Step -ge $StartStep ] && [ $Step -le $EndStep ]
then
    echo -n "Step 2: Starting reset databases ..."
    echo -e "\n################################################################################################## Starting reset databases" >>${mylog}
    cd ${HOME}/2_GCFR_Standard_Packages
    bteq <Typical_database_clear_script.txt >>${mylog} 2>&1
    RC=$?
    if [ ${RC} -ne 0 ]
    then
        echo " failed. Please check log file!"
        echo -e "\n################################################################################################## End reset databases: ${RC}" >>${mylog}
        exit 1
    fi
    echo " done"
fi


Step=3
if [ $Step -ge $StartStep ] && [ $Step -le $EndStep ]
then
    echo -n "Step 3: Starting installation of GCFR ..."
    echo -e "\n################################################################################################## Starting installation GCFR" >>${mylog}
    cd ${HOME}/2_GCFR_Standard_Packages/GCFR_DDL_Code/GCFR_Implementation_Kit
    echo "" | sh runme.sh >> ${mylog} 2>&1
    RC=${PIPESTATUS[1]}
    if [ ${RC} -ne 0 ]
    then
        echo " failed. Please check log file!"
        echo -e "\n################################################################################################## End installation GCFR: ${RC}" >>${mylog}
        exit 2
    fi
    echo " done"
fi


Step=4
if [ $Step -ge $StartStep ] && [ $Step -le $EndStep ]
then
    echo -n "Step 4: Creating Training Lab Objects ..."
    echo -e "\n################################################################################################## Starting creating Training Lab" >>${mylog}
    cd ${HOME}/4_Objects_For_Exercises
    bteq <run_all.bteq >> ${mylog} 2>&1
    RC=$?
    if [ ${RC} -ne 0 ]
    then
        echo " failed. Please check log file!"
        echo -e "\n################################################################################################## End creating Trainig Lab: ${RC}" >>${mylog}
        exit 3
    fi
    echo " done"
fi
