-- search and replace the following values to your naming
-- <GCFR_V> = View database for GCFR metadata tables
-- <UTL_V> = Utility view database for BMAP and BKEY tables
REPLACE VIEW <GCFR_V>.Check_GCFR_Processes AS
SELECT
    processes.Process_Name
    ,processes.Description AS Process_Description
    ,processes.Process_Type
    ,process_type.Process_Type_Name
    ,process_type.Description AS Process_Type_Description
    ,processes.ctl_id
    ,source_system.system_name
    ,source_system.description AS Source_System_Description
    ,processes.In_DB_Name
    ,processes.In_Object_Name
    ,CASE
        WHEN Column_Errors.Num_INP_Object_Columns = 0 THEN 'N'
        ELSE 'Y'
     END AS INP_Object_Found
    ,processes.Out_DB_Name
    ,processes.Out_Object_Name
    ,CASE
        WHEN Column_Errors.Num_OUT_Object_Columns = 0 THEN 'N'
        ELSE 'Y'
     END AS OUT_Object_Found
    ,processes.Target_TableDatabaseName
    ,processes.Target_TableName
    ,CASE
        WHEN Column_Errors.Num_Target_Table_Columns = 0 THEN 'N'
        ELSE 'Y'
     END AS Target_Table_Found
    ,COALESCE(Column_Errors.Num_INP_Object_Columns, 0) AS Num_INP_Object_Columns
    ,COALESCE(Column_Errors.Num_OUT_Object_Columns, 0) AS Num_OUT_Object_Columns
    ,COALESCE(Column_Errors.Num_Target_Table_Columns, 0) AS Num_Target_Table_Columns
    ,COALESCE(System_File.Num_of_System_Files, 0) AS Num_of_System_Files_assigned
    ,CASE
        -- Check Files assigned to Processes (mandatory assignements only)
        WHEN processes.process_type IN (10, 11, 12, 13, 14, 16, 17, 18, 19, 20) AND System_File.Num_of_System_Files <> 1 THEN 'Err'
        WHEN System_File.Num_of_System_Files IS NULL THEN 'N/A'
        ELSE 'OK'
     END AS System_File_Status
    ,CASE
        WHEN processes.process_type = 21 AND Key_Set.key_set_id IS NULL THEN 'Err'
        WHEN processes.process_type <> 21 THEN 'N/A'
        ELSE 'OK'
     END AS BKEY_Key_Set_Status
    ,CASE
        WHEN processes.process_type = 21 AND Key_Domain.key_set_id IS NULL THEN 'Err'
        WHEN processes.process_type <> 21 THEN 'N/A'
        ELSE 'OK'
     END AS BKEY_Domain_Status
    ,CASE
        WHEN processes.process_type = 21 AND BKEY_Key_Map_Table.databasename IS NULL THEN 'N'
        WHEN processes.process_type <> 21 THEN 'N/A'
        ELSE 'Y'
     END AS BKEY_Key_Map_Table_Found
    ,CASE
        WHEN processes.process_type = 21 AND BKEY_Key_Map_Table.databasename IS NOT NULL AND BKEY_Key_Map_Table.tablekind = 'V' THEN 'View'
        WHEN processes.process_type = 21 AND BKEY_Key_Map_Table.databasename IS NOT NULL AND BKEY_Key_Map_Table.tablekind IN ('T', 'O') THEN 'Table'
     END AS BKEY_Key_Map_Table_Is_Type
    ,CASE
        WHEN processes.process_type = 22 AND Code_Set.code_set_id IS NULL THEN 'Err'
        WHEN processes.process_type <> 22 THEN 'N/A'
        ELSE 'OK'
     END AS BMAP_Code_Set_Status
    ,CASE
        WHEN processes.process_type = 22 AND Code_Domain.code_set_id IS NULL THEN 'Err'
        WHEN processes.process_type <> 22 THEN 'N/A'
        ELSE 'OK'
     END AS BMAP_Domain_Status
    ,CASE
        WHEN processes.process_type = 22 AND BMAP_Code_Map_Table.databasename IS NULL THEN 'N'
        WHEN processes.process_type <> 22 THEN 'N/A'
        ELSE 'Y'
     END AS BMAP_Code_Map_Table_Found
    ,CASE
        WHEN processes.process_type = 22 AND BMAP_Code_Map_Table.databasename IS NOT NULL AND BMAP_Code_Map_Table.tablekind = 'V' THEN 'View'
        WHEN processes.process_type = 22 AND BMAP_Code_Map_Table.databasename IS NOT NULL AND BMAP_Code_Map_Table.tablekind IN ('T', 'O') THEN 'Table'
     END AS BMAP_Code_Map_Table_Is_Type
    ,Column_Errors.TCE_OUT_Target_Diff
    ,Column_Errors.TCE_INP_OUT_Diff
    ,Column_Errors.TCE_in_Target
    ,CASE
        WHEN processes.process_type IN (23, 24, 25) AND Column_Errors.TCE_in_Tfm_KeyCol = 0 AND (Column_Errors.Num_Key_Columns = 0 OR Column_Errors.Num_Key_Columns IS NULL) THEN 1
        WHEN processes.process_type IN (23, 24, 25) THEN Column_Errors.TCE_in_Tfm_KeyCol
        ELSE 0
     END AS TCE_in_Transform_KeyCol
    ,CASE
        WHEN processes.process_type IN (24)     AND Column_Errors.Num_tech_col_type2 = 0 THEN 1
        WHEN processes.process_type IN (23, 25) AND Column_Errors.Num_tech_col_type2 > 0 THEN 1
        ELSE 0
     END AS TCE_in_Process_Type
    ,CASE
        WHEN Streams.Cycle_Freq_Code = 0 AND Column_Errors.Num_tech_col_type1 < 10 AND processes.process_type IN (23, 24, 25) THEN 1
        WHEN Streams.Cycle_Freq_Code > 0 AND Column_Errors.Num_tech_col_type1 < 8 AND processes.process_type IN (23, 24, 25) THEN 1
        ELSE 0
     END AS TCE_in_Tech_Columns
    ,Column_Errors.TCE_OUT_Target_Diff + Column_Errors.TCE_INP_OUT_Diff + Column_Errors.TCE_in_Target + TCE_in_Transform_KeyCol + TCE_in_Process_Type + TCE_in_Tech_Columns AS Sum_TCE
    ,Sum_TCE
        + (CASE WHEN System_File_Status IN ('OK', 'N/A') THEN 0 ELSE 1 END)
        + (CASE WHEN BKEY_Key_Set_Status IN ('OK', 'N/A') THEN 0 ELSE 1 END)
        + (CASE WHEN BKEY_Domain_Status IN ('OK', 'N/A') THEN 0 ELSE 1 END)
        + (CASE WHEN BKEY_Key_Map_Table_Found IN ('Y', 'N/A') THEN 0 ELSE 1 END)
        + (CASE WHEN BMAP_Code_Set_Status IN ('OK', 'N/A') THEN 0 ELSE 1 END)
        + (CASE WHEN BMAP_Domain_Status IN ('OK', 'N/A') THEN 0 ELSE 1 END)
        + (CASE WHEN BMAP_Code_Map_Table_Found IN ('Y', 'N/A') THEN 0 ELSE 1 END)
        AS Fail_Indicator

FROM <GCFR_V>.gcfr_process AS processes

LEFT JOIN <GCFR_V>.gcfr_system AS source_system
  ON source_system.ctl_id = processes.ctl_id

LEFT JOIN <GCFR_V>.gcfr_process_type AS process_type
  ON process_type.Process_Type = processes.Process_Type

LEFT JOIN <GCFR_V>.GCFR_Stream AS Streams
ON Streams.stream_key = processes.stream_key

LEFT JOIN
    (
        SELECT
            x01.process_name
            ,SUM(
                    CASE
                        WHEN XXY.GCFR_tech_column_type = 0 AND INP_Object_Columns.columnname IS NOT NULL THEN 1
                        ELSE 0
                    END
                ) AS Num_INP_Object_Columns
            ,SUM(
                    CASE
                        WHEN XXY.GCFR_tech_column_type = 0 AND OUT_Object_Columns.columnname IS NOT NULL THEN 1
                        ELSE 0
                    END
                ) AS Num_OUT_Object_Columns
            ,SUM(
                    CASE
                        WHEN XXY.GCFR_tech_column_type = 0 AND Target_Table_Columns.columnname IS NOT NULL THEN 1
                        ELSE 0
                    END
                ) AS Num_Target_Table_Columns
            ,SUM(
                    CASE
                        WHEN Transform_KeyCol.Key_column IS NOT NULL THEN 1
                        ELSE 0
                    END
                ) AS Num_Key_Columns
            ,SUM(
                    (CASE
                        WHEN x01.process_type IN (23)     AND XXY.GCFR_tech_column_type IN (1, 2) AND INP_Object_Columns.columnname IS NOT NULL THEN 1
                        WHEN x01.process_type IN (24, 25) AND XXY.GCFR_tech_column_type IN (1)    AND INP_Object_Columns.columnname IS NOT NULL THEN 1
                        ELSE 0
                     END)
                ) AS TCE_tech_column_in_INP_Object
            ,SUM(
                    (CASE
                        WHEN XXY.GCFR_tech_column_type = 1 AND OUT_Object_Columns.columnname IS NOT NULL THEN 1
                        ELSE 0
                     END)
                ) AS num_tech_column_in_OUT_Object
            ,SUM(
                    (CASE
                        WHEN x01.process_type IN (13,14,17,18,20,41,42,43,44) AND OUT_Object_Columns.columnname IS NOT NULL AND Target_Table_Columns.columnname IS NULL THEN 1
                        WHEN x01.process_type IN (13,14,17,18,20,41,42,43,44) AND OUT_Object_Columns.columnname IS NULL AND Target_Table_Columns.columnname IS NOT NULL THEN 1
                        ELSE 0
                     END)
                ) AS TCE_OUT_Target_Diff
            ,SUM(
                    (CASE
                        WHEN XXY.GCFR_tech_column_type > 0 THEN 0
                        WHEN x01.process_type IN (23,24,25) AND INP_Object_Columns.columnname IS NOT NULL AND OUT_Object_Columns.columnname IS NULL THEN 1
                        WHEN x01.process_type IN (23,24,25) AND INP_Object_Columns.columnname IS NULL AND OUT_Object_Columns.columnname IS NOT NULL THEN 1
                        ELSE 0
                     END)
                ) AS TCE_INP_OUT_Diff
            ,SUM(
                    (CASE
                        WHEN XXY.GCFR_tech_column_type > 0 THEN 0
                        WHEN x01.process_type IN (23,24,25) AND Target_Table_Columns.Nullable = 'N' AND Target_Table_Columns.DefaultValue IS NULL AND OUT_Object_Columns.columnname IS NULL THEN 1
                        WHEN x01.process_type IN (23,24,25) AND Target_Table_Columns.columnname IS NULL AND (INP_Object_Columns.columnname IS NOT NULL OR OUT_Object_Columns.columnname IS NOT NULL) THEN 1
                        ELSE 0
                     END)
                ) AS TCE_in_Target
            ,SUM(
                    (CASE
                        WHEN x01.process_type IN (23,24,25) AND Transform_KeyCol.Key_column IS NOT NULL AND Target_Table_Columns.columnname IS NOT NULL AND OUT_Object_Columns.columnname IS NOT NULL THEN 0 -- OK
                        WHEN x01.process_type IN (23,24,25) AND Transform_KeyCol.Key_column IS NULL THEN 0 -- OK
                        ELSE 1 -- Not OK
                     END)
                ) AS TCE_in_Tfm_KeyCol
            ,SUM(
                    (CASE
                        WHEN XXY.GCFR_tech_column_type = 1 THEN 1
                        ELSE 0
                     END)
                ) AS Num_tech_col_type1
            ,SUM(
                    (CASE
                        WHEN XXY.GCFR_tech_column_type = 2 THEN 1
                        ELSE 0
                     END)
                ) AS Num_tech_col_type2

        FROM <GCFR_V>.gcfr_process AS x01
        
        JOIN
            (
                -- generate list of all columns (INP, OUT, Target) related to that process
                SELECT y01.process_name, y02.columnname
                      ,CAST((CASE
                                WHEN y02.columnname IN ('start_date', 'end_date', 'start_ts', 'end_ts', 'record_deleted_flag', 'ctl_id', 'process_name', 'process_id', 'update_process_name', 'update_process_id') THEN 1
                                WHEN y02.columnname IN ('GCFR_Delta_Action_Code') THEN 2
                                ELSE 0
                            END) AS BYTEINT) AS GCFR_tech_column_type
                  FROM <GCFR_V>.gcfr_process AS y01
                  JOIN dbc.columnsv AS y02
                    ON y02.databasename = y01.In_DB_Name
                   AND y02.TABLENAME    = y01.In_Object_Name
                 UNION
                SELECT y03.process_name, y04.columnname
                      ,CAST((CASE
                                WHEN y04.columnname IN ('start_date', 'end_date', 'start_ts', 'end_ts', 'record_deleted_flag', 'ctl_id', 'process_name', 'process_id', 'update_process_name', 'update_process_id') THEN 1
                                WHEN y04.columnname IN ('GCFR_Delta_Action_Code') THEN 2
                                ELSE 0
                            END) AS BYTEINT) AS GCFR_tech_column_type
                  FROM <GCFR_V>.gcfr_process AS y03
                  JOIN dbc.columnsv AS y04
                    ON y04.databasename = y03.Out_DB_Name
                   AND y04.TABLENAME    = y03.Out_Object_Name
                 UNION
                SELECT y05.process_name, y06.columnname
                      ,CAST((CASE
                                WHEN y06.columnname IN ('start_date', 'end_date', 'start_ts', 'end_ts', 'record_deleted_flag', 'ctl_id', 'process_name', 'process_id', 'update_process_name', 'update_process_id') THEN 1
                                WHEN y06.columnname IN ('GCFR_Delta_Action_Code') THEN 2
                                ELSE 0
                            END) AS BYTEINT) AS GCFR_tech_column_type
                  FROM <GCFR_V>.gcfr_process AS y05
                  JOIN dbc.columnsv AS y06
                    ON y06.databasename = y05.Target_TableDatabaseName
                   AND y06.TABLENAME    = y05.Target_TableName
                 UNION
                SELECT y07.process_name, y08.key_column
                      ,CAST((CASE
                                WHEN y08.key_column IN ('start_date', 'end_date', 'start_ts', 'end_ts', 'record_deleted_flag', 'ctl_id', 'process_name', 'process_id', 'update_process_name', 'update_process_id') THEN 1
                                WHEN y08.key_column IN ('GCFR_Delta_Action_Code') THEN 2
                                ELSE 0
                            END) AS BYTEINT) AS GCFR_tech_column_type
                  FROM <GCFR_V>.gcfr_process AS y07
                  JOIN <GCFR_V>.gcfr_transform_keycol AS y08
                    ON y08.Out_DB_Name     = y07.Out_DB_Name
                   AND y08.Out_Object_Name = y07.Out_Object_Name
            ) AS XXY
        ON x01.process_name = XXY.process_name
        
        LEFT JOIN dbc.columnsv AS INP_Object_Columns
          ON INP_Object_Columns.databasename = x01.In_DB_Name
         AND INP_Object_Columns.TABLENAME    = x01.In_Object_Name
         AND INP_Object_Columns.columnname   = XXY.columnname
        
        LEFT JOIN dbc.columnsv AS OUT_Object_Columns
          ON OUT_Object_Columns.databasename = x01.Out_DB_Name
         AND OUT_Object_Columns.TABLENAME    = x01.Out_Object_Name
         AND OUT_Object_Columns.columnname   = XXY.columnname
        
        LEFT JOIN dbc.columnsv AS Target_Table_Columns
          ON Target_Table_Columns.databasename = x01.Target_TableDatabaseName
         AND Target_Table_Columns.TABLENAME    = x01.Target_TableName
         AND Target_Table_Columns.columnname   = XXY.columnname

        LEFT JOIN <GCFR_V>.GCFR_Transform_KeyCol AS Transform_KeyCol
          ON Transform_KeyCol.out_db_name     = x01.Out_DB_Name
         AND Transform_KeyCol.out_object_name = x01.Out_Object_Name
         AND Transform_KeyCol.Key_column      = XXY.columnname

        GROUP BY 1
    ) AS Column_Errors
ON Column_Errors.process_name = processes.process_name

LEFT JOIN
    (
        SELECT process_name, COUNT(*) AS Num_of_System_Files
        FROM <GCFR_V>.GCFR_File_Process AS t01
        JOIN <GCFR_V>.GCFR_System_File AS t02
        ON t01.file_id = t02.file_id
        GROUP BY 1
    ) AS System_File
ON System_File.process_name = processes.process_name

LEFT JOIN <UTL_V>.BKEY_Key_Set AS Key_Set
ON Key_Set.key_set_id = processes.key_set_id

LEFT JOIN
    (
        SELECT TRIM(databasename) AS databasename, TRIM(TABLENAME) AS TABLENAME, tablekind
        FROM dbc.tablesv
    ) AS BKEY_Key_Map_Table
ON BKEY_Key_Map_Table.databasename = Key_Set.Key_Table_DB_Name
AND BKEY_Key_Map_Table.TABLENAME = Key_Set.Key_Table_Name

LEFT JOIN <UTL_V>.BKEY_Domain AS Key_Domain
ON Key_Domain.key_set_id = processes.key_set_id
AND Key_Domain.domain_id = processes.domain_id

LEFT JOIN <UTL_V>.BMAP_Code_Set AS Code_Set
ON Code_Set.code_set_id = processes.code_set_id

LEFT JOIN
    (
        SELECT TRIM(databasename) AS databasename, TRIM(TABLENAME) AS TABLENAME, tablekind
        FROM dbc.tablesv
    ) AS BMAP_Code_Map_Table
ON BMAP_Code_Map_Table.databasename = Code_Set.Map_Table_DB_Name
AND BMAP_Code_Map_Table.TABLENAME = Code_Set.Map_Table_Name

LEFT JOIN <UTL_V>.BMAP_Domain AS Code_Domain
ON Code_Domain.code_set_id = processes.code_set_id
AND Code_Domain.domain_id = processes.domain_id

WHERE processes.process_type IN (13, 14, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 29, 30, 32, 35, 40, 41, 42, 43, 44)
;

comment on view <GCFR_V>.Check_GCFR_Processes is 'Show GCFR processes and extensively check and show inconsistencies';
comment on column <GCFR_V>.Check_GCFR_Processes.Process_Name is 'Process Name from GCFR_Process View';
comment on column <GCFR_V>.Check_GCFR_Processes.Process_Description is 'Process Description from GCFR_Process View';
comment on column <GCFR_V>.Check_GCFR_Processes.Process_Type is 'Process Type from GCFR_Process View';
comment on column <GCFR_V>.Check_GCFR_Processes.Process_Type_Name is 'Process Type Name from GCFR_Process_Type View';
comment on column <GCFR_V>.Check_GCFR_Processes.Process_Type_Description is 'Process Type Description from GCFR_Process_Type View';
comment on column <GCFR_V>.Check_GCFR_Processes.Ctl_Id is 'Source System ID from GCFR_Process View';
comment on column <GCFR_V>.Check_GCFR_Processes.System_Name is 'Source System Name from GCFR_System View';
comment on column <GCFR_V>.Check_GCFR_Processes.Source_System_Description is 'Source System Description from GCFR_System View';
comment on column <GCFR_V>.Check_GCFR_Processes.In_DB_Name is 'In which Database is the Input Object';
comment on column <GCFR_V>.Check_GCFR_Processes.In_Object_Name is 'The name of the Input Object';
comment on column <GCFR_V>.Check_GCFR_Processes.INP_Object_Found is 'Y = The Input Object has been found, N = The Input Object has not been found, N leads to an error in GCFR';
comment on column <GCFR_V>.Check_GCFR_Processes.Out_DB_Name is 'In which Database is the Output Object';
comment on column <GCFR_V>.Check_GCFR_Processes.Out_Object_Name is 'The name of the Output Object';
comment on column <GCFR_V>.Check_GCFR_Processes.OUT_Object_Found is 'Y = The Output Object has been found, N = The Output Object has not been found, N leads to an error in GCFR';
comment on column <GCFR_V>.Check_GCFR_Processes.Target_TableDatabaseName is 'In which Database is the Target Table';
comment on column <GCFR_V>.Check_GCFR_Processes.Target_TableName is 'The name of the Target Table';
comment on column <GCFR_V>.Check_GCFR_Processes.Target_Table_Found is 'Y = The Target Table has been found, N = The Target Table has not been found, N leads to an error in GCFR';
comment on column <GCFR_V>.Check_GCFR_Processes.Num_INP_Object_Columns is 'Number of Data Columns in Input Object';
comment on column <GCFR_V>.Check_GCFR_Processes.Num_OUT_Object_Columns is 'Number of Data Columns in Output Object';
comment on column <GCFR_V>.Check_GCFR_Processes.Num_Target_Table_Columns is 'Number of Data Columns in Target Table';
comment on column <GCFR_V>.Check_GCFR_Processes.Num_of_System_Files_assigned is 'Number of System Files assigned to this process';
comment on column <GCFR_V>.Check_GCFR_Processes.System_File_Status is 'OK = no problem, N/A = not applicable for this process type, Err = Error in (not) assigned files to process';
comment on column <GCFR_V>.Check_GCFR_Processes.BKEY_Key_Set_Status is 'OK = no problem, N/A = not applicable for this process type, Err = No existing Key_Set_Id available in BKEY_Key_Set table';
comment on column <GCFR_V>.Check_GCFR_Processes.BKEY_Domain_Status is 'OK = no problem, N/A = not applicable for this process type, Err = No existing Domain_Id available in BKEY_Domain table';
comment on column <GCFR_V>.Check_GCFR_Processes.BKEY_Key_Map_Table_Found is 'Y = The Key Map Table has been found, N = The Key Map Table has not been found, N/A = not applicable for this process type, N leads to an error in GCFR';
comment on column <GCFR_V>.Check_GCFR_Processes.BKEY_Key_Map_Table_is_Type is 'Registered Key Map Table is of type (view or table)';
comment on column <GCFR_V>.Check_GCFR_Processes.BMAP_Code_Set_Status is 'OK = no problem, N/A = not applicable for this process type, Err = No existing Code_Set_Id available in BMAP_Key_Set table';
comment on column <GCFR_V>.Check_GCFR_Processes.BMAP_Domain_Status is 'OK = no problem, N/A = not applicable for this process type, Err = No existing Code_Domain available in BMAP_Domain table';
comment on column <GCFR_V>.Check_GCFR_Processes.BMAP_Code_Map_Table_Found is 'Y = The Code Map Table has been found, N = The Code Map Table has not been found, N/A = not applicable for this process type, N leads to an error in GCFR';
comment on column <GCFR_V>.Check_GCFR_Processes.BMAP_Code_Map_Table_is_Type is 'Registered Code Map Table is of type (view or table)';
comment on column <GCFR_V>.Check_GCFR_Processes.TCE_OUT_Target_Diff is 'Transform Column Error: the columnames between Output Object and Target Table do not match';
comment on column <GCFR_V>.Check_GCFR_Processes.TCE_INP_OUT_Diff is 'Transform Column Error: the columnames between Input and Output Objects do not match';
comment on column <GCFR_V>.Check_GCFR_Processes.TCE_in_Target is 'Transform Column Error: target column is defined as not null and has no default value and is missing in Output Object';
comment on column <GCFR_V>.Check_GCFR_Processes.TCE_in_Transform_KeyCol is 'Transform Column Error: no Columns defined as Key in GCFR_Transform_KeyCol or defined Key does not exist as column in Target Table';
comment on column <GCFR_V>.Check_GCFR_Processes.TCE_in_Process_Type is 'Transform Column Error: Process_Type is defined as delta, but missing column GCFR_Delta_Action_Code or vice versa';
comment on column <GCFR_V>.Check_GCFR_Processes.TCE_in_Tech_Columns is 'Transform Column Error: Too few GCFR technical columns depending on Stream-Cycle-Frequency-Code';
comment on column <GCFR_V>.Check_GCFR_Processes.Sum_TCE is 'Summarize all TCE* columns to show errors (easy to order in result set), a value greater then zero will very likely cause an abort in the GCFR process';
comment on column <GCFR_V>.Check_GCFR_Processes.Fail_Indicator is 'Summarize all TCE* columns plus File and BKEY/BMAP status, a value greater then zero will very likely cause an abort in the GCFR process';
