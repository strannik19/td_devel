#!/bin/bash

# This script is for resetting an aborted GCFR Training Lab run back to start
# I requires everything prepared:
#   Folders with Training Lab scripts
#   Existing GCFR installation

export mylog="${HOME}/reset_Training_Lab.log"

rm -f ${mylog}

echo -n "Starting preparation input data, logs and scripts ..."
echo -e "\n################################################################################################## Starting prepare folders" >>${mylog}
{
    cd /GCFR_Root
    rm {logs,logon}/*
    rm scripts/[A-Z]*
    rm export_data/archive/*
    rm export_data/[A-Z]*

    cd source_data
    mv customer/archive/CUSTOMER_* customer/
    rm customer/archive/*
    mv accounts/archive/ACCOUNTS_* accounts/
    rm accounts/archive/*
    mv transactions/archive/TRANSACTIONS_* transactions
    rm transactions/archive/*
} >>${mylog} 2>&1
echo " done"

echo -n "Starting reset databases ..."
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

echo -n "Starting installation of GCFR ..."
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

echo -n "Creating Training Lab Objects ..."
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
