#!/bin/bash

#
# This is to search and replace the limitation of 30 bytes for process_name and update_user
# Change into directory GCFR_DDL_Code and execute it there!
#

if [ ${PWD##*/} != "GCFR_DDL_Code" ]
then
    echo "Please change into the DDL code base folder of GCFR before executing!"
    exit 1
fi

REPLACE_FILE="/tmp/replace.txt"
GREP_SEARCH_FILE="/tmp/grep_search.txt"

trap "rm -f ${REPLACE_FILE} ${GREP_SEARCH_FILE}>/dev/null 2>&1" EXIT

#
# Check if temporary replacement value file exists and delete
#
if [ -e ${REPLACE_FILE} ]
then
    rm -f ${REPLACE_FILE}
fi

VARIABLES="Process_Name"
VARIABLES="${VARIABLES} Calling_API"
VARIABLES="${VARIABLES} Logger_Name"
VARIABLES="${VARIABLES} iAPI_Name"
VARIABLES="${VARIABLES} iCalling_API"
VARIABLES="${VARIABLES} iCalling_API_Name"
VARIABLES="${VARIABLES} iLogger_Name"
VARIABLES="${VARIABLES} iPassword_String"
VARIABLES="${VARIABLES} iProcess_Name"
VARIABLES="${VARIABLES} iRelated_Process_Name"
VARIABLES="${VARIABLES} iTD_Server"
VARIABLES="${VARIABLES} iTD_User_Name"
VARIABLES="${VARIABLES} iWork_DB_Name"
VARIABLES="${VARIABLES} oProcess_Name"
VARIABLES="${VARIABLES} oProcess_Name_ET"
VARIABLES="${VARIABLES} oRelated_Process_Name"
VARIABLES="${VARIABLES} oUpdate_User"
VARIABLES="${VARIABLES} Related_Process_Name"
VARIABLES="${VARIABLES} SLA_Object"
VARIABLES="${VARIABLES} Update_Process_Name"
VARIABLES="${VARIABLES} Update_User"
VARIABLES="${VARIABLES} vLogger_Name"
VARIABLES="${VARIABLES} vPID_Update_User"
VARIABLES="${VARIABLES} vPR_Update_User"
VARIABLES="${VARIABLES} vProcess_Name_ET"
VARIABLES="${VARIABLES} vRelated_Process_Name"
VARIABLES="${VARIABLES} vPS_Update_User"
VARIABLES="${VARIABLES} vRP_Update_User"
VARIABLES="${VARIABLES} vS_DB_Name"
VARIABLES="${VARIABLES} vS_Tbl_Name"
VARIABLES="${VARIABLES} vSF_Update_User"
VARIABLES="${VARIABLES} vSP_Name"
VARIABLES="${VARIABLES} vTemp_TableName"
VARIABLES="${VARIABLES} vUpdate_User"
VARIABLES="${VARIABLES} vWork_DB_Name"

{
    for VARIABLE in ${VARIABLES}
    do
        echo "s/([, 	])${VARIABLE}[ 	]+VARCHAR\(30\)/\1${VARIABLE}                        VARCHAR\(128\)/g"
    done
} >${REPLACE_FILE}

if [ $? -ne 0 ]
then
    echo "Error creating temporary replacement file"
    exit 2
fi

#
# Generate search string for grep
# Purpose is to do one grep per file to see if an sed is required on that file
#
if [ -e ${GREP_SEARCH_FILE} ]
then
    rm -f ${GREP_SEARCH_FILE}
fi

{
    for VARIABLE in ${VARIABLES}
    do
        echo "[\, 	]${VARIABLE}[ 	]+VARCHAR\(30\)"
    done
} >${GREP_SEARCH_FILE}

if [ $? -ne 0 ]
then
    echo "Error creating temporary grep search file"
    exit 3
fi


#
# Run the processing
#
for X in $(find . -type f -print)
do
    echo -ne "\n$X"
    COUNT=$(egrep -f "${GREP_SEARCH_FILE}" -c "${X}")
    if [ ${COUNT} -gt 0 ]
    then
        echo -n " ... changed"
        sed -rf ${REPLACE_FILE} -i "${X}" 2>/dev/null
    fi
done
echo

#
# Check the files and remove output which are not supposed to get changed
#
echo ">>> Start checking all files again, if we missed anything"
egrep -i "CHAR\s*\(\s*30\s*\)" */* 2>/dev/null \
    | grep -vw Stream_Name \
    | grep -vw Language_Name \
    | grep -vw Corporate_Entity_Name \
    | grep -vw Process_Param_Name \
    | grep -vw Process_Param_Value \
    | grep -vw Process_Param_Cast \
    | grep -vw Process_Type_Name \
    | grep -vw Process_Type_Param_Value \
    | grep -vw Process_Type_Param_Cast \
    | grep -vw System_Name \
    | grep -vw System_Defined_Code \
    | grep -vw iSystem_Code \
    | grep -vw iExecution_Text \
    | grep -vw iAlias_Name \
    | grep -vw iAliasName \
    | grep -vw iAlias1 \
    | grep -vw iAlias2 \
    | grep -vw iTag_Var \
    | grep -vw cGCFR_DELTA_ACTION_CODE \
    | grep -vw vBusiness_Date_Cycle_Start_Ts \
    | grep -vw vParameter_Casting \
    | grep -vw cIns_Tab_Suffix \
    | grep -vw Stream_Key \
    | grep -vw iBusiness_Date_Cycle_Start_Ts \
    | grep -vw cINS_TAB_SUFFIX \
    | grep -vw vPS_System_Name \
    | grep -vw vStream_Name \
    | grep -vw oBusiness_Date_Cycle_Start_Ts \
    | grep -vw Business_Date_Cycle_Start_Ts \
    | grep -vw iAliasNameFront \
    | grep -vw SLA_Level \
    | grep -vw oSystem_Name \
    | grep -vw iAliasNamEnd \
    | grep -vw cImg_Tab_Suffix \
    | grep -vw vParam_Casting \
    | grep -vw iAliasNameEnd \
    | grep -vw vOperator_Name \
    | grep -vw cIMG_TAB_SUFFIX \
    | grep -vw oStream_Name \
    | grep -vw iParam_Group \
    | grep -vw oCE_Name \
    | grep -vw Param_Group \
    | grep -vw iStream_Name

echo ">>> No files are supposed to appear between those two lines!"
