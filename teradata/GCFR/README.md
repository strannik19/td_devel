Here are some helpful views to enhance the quality of development with GCFR.

You might need to adapt a bit. At least, database naming.


Check_GCFR_Objects.ddl
======================
Show objects in certain databases, if they are used in any GCFR_Process either as Input/Output or Target!

Check_GCFR_Processes.ddl
========================
Show GCFR processes with information to identify errors in advance, which will lead to an abort in running that process:
* Look if Input/Output or Target object exists or not.
* Check data columns of Input and Output Objects and Target Table if they match.
* Show number of columns in Input and Output Objects and Target Table. Equal numbers do not mean: no problem. The problem will be shown in other TCE columns
* Check if missing column in Input Object is defined as NOT NULL with no default value in Target Table.
* Check if Output Object has keys defined in GCFR_Transform_KeyCol if Process_Type 23, 24 or 25 and if they exist in Target Table.
* Check if Input Object has column GCFR_Delta_Action_Code if Process_Type 24.
* Check if Target Table has columns start_ts and end_ts if Stream is Intraday.

Important column description:

Column Name | Description
----------- | -----------
Status_Stream_BusDate | Status of the BusinessDate for the Stream (Started, Ended)
Status_Stream | Status of the Stream within the BusinessDate (Started, Ended)
Business_Date | Current BusinessDate
Business_Date_Cycle_Start_TS | Current Cycle Start
INP_Object_Found | Y = The Input Object has been found, N = The Input Object has not been found.
OUT_Object_Found | Y = The Output Object has been found, N = The Output Object has not been found.
Target_Table_Found | Y = The Target Table has been found, N = The Target Table has not been found.
Num_INP_Object_Columns | Number of Data Columns in Input Object.
Num_OUT_Object_Columns | Number of Data Columns in Output Object.
Num_Target_Table_Columns | Number of Data Columns in Target Table.
Num_of_System_Files_assigned | Number of System Files assigned to this process
System_File_Status | OK = no problem, N/A = no applicable for this process type, Err = Error in (not) assigned files to process
BKEY_Key_Set_Status | OK = no problem, N/A = no applicable for this process type, Err = No existing Key_Set_Id available in BKEY_Key_Set table
BKEY_Domain_Status | OK = no problem, N/A = no applicable for this process type, Err = No existing Domain_Id available in BKEY_Domain table
BKEY_Key_Map_Table_Found | Y = The Key Map Table has been found, N = The Key Map Table has not been found, N/A = not applicable for this process type, N leads to an error in GCFR
BKEY_Key_Map_Table_is_Type | Registered Key Map Table is of type (view or table)
BMAP_Code_Set_Status | OK = no problem, N/A = no applicable for this process type, Err = No existing Code_Set_Id available in BMAP_Key_Set table
BMAP_Domain_Status | OK = no problem, N/A = no applicable for this process type, Err = No existing Code_Domain available in BMAP_Domain table
BMAP_Code_Map_Table_Found | Y = The Code Map Table has been found, N = The Code Map Table has not been found, N/A = not applicable for this process type, N leads to an error in GCFR
BMAP_Code_Map_Table_is_Type | Registered Code Map Table is of type (view or table)
TCE_OUT_Target_Diff | Transform Column Error: the Column Names between Output Object and Target Table do not match.
TCE_INP_OUT_Diff | Transform Column Error: the Column Names between Input and Output Objects do not match.
TCE_in_Target | Transform Column Error: Target Column is defined as NOT NULL and has no default value and is missing in Input/Output Object. Or column exists in Input/Output Object but not in Target Table.
TCE_in_Transform_KeyCol | Transform Column Error: no columns defined as Key in GCFR_Transform_KeyCol or defined Key does not exist as Column(s) in Target Table.
TCE_in_Process_Type | Transform Column Error: Process_Type is defined as "Delta", but Column GCFR_Delta_Action_Code is missing in Input Object or Process_Type is defined as "Full" or "Transaction" and Column GCFR_Delta_Action_Code exists in Input Object.
TCE_in_Tech_Columns | Transform Column Error: Too few GCFR Technical Columns depending on Stream-Cycle-Frequency-Code (at least 8 for Daily or longer, 10 for IntraDay).
Sum_TCE | Summarize all TCE* columns to show errors (easy to order in result set), a number greater then zero will very likely cause an abort in the GCFR process.
Fail_Indicator | Summarize all TCE* columns plus File and BKEY/BMAP status, a value greater then zero will very likely cause an abort in the GCFR process.
PI_Transform_KeyCol_Mismatch | Value greater than 0 means Target Table has column in PI which is not used as Transform_KeyCol (technically no error, but inefficient query)

Check_GCFR_TargetPopulation.ddl
===============================
Show target tables and show number of processes populating it!

Check_Transform_KeyCol.ddl
==========================
For all processes with process_types of 23, 24 and 25, count the number of key columns.
If the count is 0, then this process will fail.

Check_Transform_Process_Type.ddl
================================
Compares the defined process_type in GCFR_Process with the definition of the input view.
Process_type 23 does not allow to have the column "GCFR_Delta_Action_Code", whilst process_type 24 requires this column to be runable.

GCFR_UT_BKEY_Register_New
=========================
Stored procedure to register a new key set and also generate all required tables and views with one step.
Only domains need to be registered additionally as usual.

Parameter Name | Description
-------------- | -----------
iKey_Set_Id | Specify the Key_Set_Id here
iDescription | A description for this new Key_Set_Id
iTableDatabaseName | Databasename where Key_Set table will be created
iViewDatabaseName | Databasename where Key_set view will be created
iKey_Table_Name | Table name for Key_Set
iBIGINT_Flag | If using BIGINT (1) or INTEGER (0)
iIndividual_Next_Id_Table_Flag | not supported yet
OMessage | Output message has multiple lines

Gen_GCFR_Calls.ddl
==================
This view generates a list of process executions for GCFR_Process table. Either to use in SLJM (with variables) or directly in SQL Assistant.
If using in SQL Assistant, the database names might need to get changed to the correct environment database name.

Gen_GCFR_Comments.ddl
=====================
Generates simple "comment on" commands for input and output views from GCFR_Process table, to put some information onto the views.

Gen_SLJM_Job.ddl
================
After ordering the output by column "Absolute_Order", the execution sequence for SLJM - including parallel processing - is generated.
The output for one Stream can build the complete job file for SLJM. Therefore, the steps for one target table are set to run sequentially,
while different target tables to run in parallel (if they don't have any dependencies). Use the variable SLJMPROCLIMIT to limit the parallel
running processes per job.

SP_Compress_Process_Name.ddl
============================
With Teradata 14.10 or newer, a MVC definition can be added on non-empty tables via "ALTER TABLE" command. This procedure
* takes an input parameter of the database where to add a multi value compress definition to columns PROCESS_NAME and UPDATE_PROCESS_NAME
* uses the Process Names from GCFR_Process table to generate a string of values
* executes the alter table command, so create and drop table privileges are required on certain databases by the owning database
* also handles the IMG- and INS- tables created by GCFR (the input parameter for database must be the temporary database)
* picks up all tables in the selected database with columns PROCESS_NAME **and** UPDATE_PROCESS_NAME

Result is a command like: ```ALTER TABLE DB_XY.TABLE_YZ add process_name compress ('A', 'B', 'C'), add update_process_name compress ('A', 'B', 'C');```
