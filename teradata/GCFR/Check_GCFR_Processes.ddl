-- search and replace the following values to your naming
-- <GCFR_V> = View database for GCFR metadata tables
-- <UTL_V> = Utility view database for BMAP and BKEY tables
REPLACE VIEW <GCFR_V>.Check_GCFR_Processes AS
SELECT
    processes.Process_Name
    ,processes.Description AS Process_Description
    ,processes.Process_Type
    ,Process_Type.Process_Type_Name
    ,Process_Type.Description AS Process_Type_Description
    ,processes.Ctl_Id
    ,source_system.System_Name
    ,source_system.Description AS Source_System_Description
    ,CASE
        WHEN Open_Stream_BusDate.Processing_Flag = 0 THEN 'Started'
        WHEN Open_Stream_BusDate.Processing_Flag = 1 THEN 'Ended'
        ELSE 'Err'
     END AS Status_Stream_BusDate
    ,CASE
        WHEN Open_Stream.Processing_Flag = 0 THEN 'Started'
        WHEN Open_Stream.Processing_Flag = 1 THEN 'Ended'
        ELSE 'Err'
     END AS Status_Stream
    ,Open_Stream_BusDate.Business_Date
    ,Open_Stream.Business_Date_Cycle_Start_TS
    ,processes.In_DB_Name
    ,processes.In_Object_Name
    ,CASE
        WHEN processes.Process_Type IN (16, 19, 21, 22, 23, 24, 25, 29, 30, 35) AND Column_Errors.Num_INP_Object_Columns = 0 THEN 'N'
        WHEN processes.Process_Type NOT IN (16, 19, 21, 22, 23, 24, 25, 29, 30, 35) THEN 'N/A'
        ELSE 'Y'
     END AS INP_Object_Found
    ,processes.Out_DB_Name
    ,processes.Out_Object_Name
    ,CASE
        WHEN processes.Process_Type IN (13, 14, 17, 18, 20, 21, 22, 23, 24, 25, 29, 30, 35, 40, 41, 42, 43, 44) AND Column_Errors.Num_OUT_Object_Columns = 0 THEN 'N'
        WHEN processes.Process_Type NOT IN (13, 14, 17, 18, 20, 21, 22, 23, 24, 25, 29, 30, 35, 40, 41, 42, 43, 44) THEN 'N/A'
        ELSE 'Y'
     END AS OUT_Object_Found
    ,processes.Target_TableDatabaseName
    ,processes.Target_TableName
    ,CASE
        WHEN processes.Process_Type IN (13, 14, 17, 18, 20, 21, 22, 23, 24, 25, 29, 30, 35, 40, 41, 42, 43, 44) AND Column_Errors.Num_Target_Table_Columns = 0 THEN 'N'
        WHEN processes.Process_Type NOT IN (13, 14, 17, 18, 20, 21, 22, 23, 24, 25, 29, 30, 35, 40, 41, 42, 43, 44) THEN 'N/A'
        ELSE 'Y'
     END AS Target_Table_Found
    ,COALESCE(Column_Errors.Num_INP_Object_Columns, 0) AS Num_INP_Object_Columns
    ,COALESCE(Column_Errors.Num_OUT_Object_Columns, 0) AS Num_OUT_Object_Columns
    ,COALESCE(Column_Errors.Num_Target_Table_Columns, 0) AS Num_Target_Table_Columns
    ,COALESCE(System_File.Num_of_System_Files, 0) AS Num_of_System_Files_assigned
    ,CASE
        -- Check Files assigned to Processes (mandatory assignements only)
        WHEN processes.Process_Type IN (10, 11, 12, 13, 14, 16, 17, 18, 19, 20) AND System_File.Num_of_System_Files <> 1 THEN 'Err'
        WHEN System_File.Num_of_System_Files IS NULL THEN 'N/A'
        ELSE 'OK'
     END AS System_File_Status
    ,CASE
        WHEN processes.Process_Type = 21 AND Key_Set.Key_Set_Id IS NULL THEN 'Err'
        WHEN processes.Process_Type <> 21 THEN 'N/A'
        ELSE 'OK'
     END AS BKEY_Key_Set_Status
    ,CASE
        WHEN processes.Process_Type = 21 AND Key_Domain.Key_Set_Id IS NULL THEN 'Err'
        WHEN processes.Process_Type <> 21 THEN 'N/A'
        ELSE 'OK'
     END AS BKEY_Domain_Status
    ,CASE
        WHEN processes.Process_Type = 21 AND BKEY_Key_Map_Table.DatabaseName IS NULL THEN 'N'
        WHEN processes.Process_Type <> 21 THEN 'N/A'
        ELSE 'Y'
     END AS BKEY_Key_Map_Table_Found
    ,CASE
        WHEN processes.Process_Type = 21 AND BKEY_Key_Map_Table.DatabaseName IS NOT NULL AND BKEY_Key_Map_Table.TableKind = 'V' THEN 'View'
        WHEN processes.Process_Type = 21 AND BKEY_Key_Map_Table.DatabaseName IS NOT NULL AND BKEY_Key_Map_Table.TableKind IN ('T', 'O') THEN 'Table'
     END AS BKEY_Key_Map_Table_Is_Type
    ,CASE
        WHEN processes.Process_Type = 22 AND Code_Set.Code_Set_Id IS NULL THEN 'Err'
        WHEN processes.Process_Type <> 22 THEN 'N/A'
        ELSE 'OK'
     END AS BMAP_Code_Set_Status
    ,CASE
        WHEN processes.Process_Type = 22 AND Code_Domain.Code_Set_Id IS NULL THEN 'Err'
        WHEN processes.Process_Type <> 22 THEN 'N/A'
        ELSE 'OK'
     END AS BMAP_Domain_Status
    ,CASE
        WHEN processes.Process_Type = 22 AND BMAP_Code_Map_Table.DatabaseName IS NULL THEN 'N'
        WHEN processes.Process_Type <> 22 THEN 'N/A'
        ELSE 'Y'
     END AS BMAP_Code_Map_Table_Found
    ,CASE
        WHEN processes.Process_Type = 22 AND BMAP_Code_Map_Table.DatabaseName IS NOT NULL AND BMAP_Code_Map_Table.TableKind = 'V' THEN 'View'
        WHEN processes.Process_Type = 22 AND BMAP_Code_Map_Table.DatabaseName IS NOT NULL AND BMAP_Code_Map_Table.TableKind IN ('T', 'O') THEN 'Table'
     END AS BMAP_Code_Map_Table_Is_Type
    ,Column_Errors.TCE_OUT_Target_Diff
    ,Column_Errors.TCE_INP_OUT_Diff
    ,Column_Errors.TCE_in_Target
    ,CASE
        WHEN processes.Process_Type IN (23, 24, 25) AND Column_Errors.TCE_in_Tfm_KeyCol = 0 AND (Column_Errors.Num_Key_Columns = 0 OR Column_Errors.Num_Key_Columns IS NULL) THEN 1
        WHEN processes.Process_Type IN (23, 24, 25) THEN Column_Errors.TCE_in_Tfm_KeyCol
        ELSE 0
     END AS TCE_in_Transform_KeyCol
    ,CASE
        WHEN processes.Process_Type IN (24)     AND Column_Errors.Num_tech_col_type2 = 0 THEN 1
        WHEN processes.Process_Type IN (23, 25) AND Column_Errors.Num_tech_col_type2 > 0 THEN 1
        ELSE 0
     END AS TCE_in_Process_Type
    ,CASE
        WHEN Streams.Cycle_Freq_Code = 0 AND Column_Errors.Num_tech_col_type1 < 10 AND processes.Process_Type IN (23, 24, 25) THEN 1
        WHEN Streams.Cycle_Freq_Code > 0 AND Column_Errors.Num_tech_col_type1 < 8 AND processes.Process_Type IN (23, 24, 25) THEN 1
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
    ,CASE
        WHEN processes.Process_Type IN (23,24) THEN Column_Errors.PI_Transform_KeyCol_Diff
        WHEN processes.Process_Type IN (25) AND processes.Verification_Flag = 1 THEN Column_Errors.PI_Transform_KeyCol_Diff
        ELSE 0
     END AS PI_Transform_KeyCol_Mismatch

FROM <GCFR_V>.GCFR_Process AS processes

LEFT JOIN <GCFR_V>.GCFR_System AS source_system
  ON source_system.Ctl_Id = processes.Ctl_Id

LEFT JOIN <GCFR_V>.GCFR_Process_Type AS Process_Type
  ON Process_Type.Process_Type = processes.Process_Type

LEFT JOIN <GCFR_V>.GCFR_Stream AS Streams
ON Streams.Stream_Key = processes.Stream_Key

LEFT JOIN
    (
        SELECT
            x01.Process_Name
            ,SUM(
                    CASE
                        WHEN XXY.GCFR_tech_column_type = 0 AND INP_Object_Columns.ColumnName IS NOT NULL THEN 1
                        ELSE 0
                    END
                ) AS Num_INP_Object_Columns
            ,SUM(
                    CASE
                        WHEN XXY.GCFR_tech_column_type = 0 AND OUT_Object_Columns.ColumnName IS NOT NULL THEN 1
                        ELSE 0
                    END
                ) AS Num_OUT_Object_Columns
            ,SUM(
                    CASE
                        WHEN XXY.GCFR_tech_column_type = 0 AND Target_Table_Columns.ColumnName IS NOT NULL THEN 1
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
                        WHEN x01.Process_Type IN (23)     AND XXY.GCFR_tech_column_type IN (1, 2) AND INP_Object_Columns.ColumnName IS NOT NULL THEN 1
                        WHEN x01.Process_Type IN (24, 25) AND XXY.GCFR_tech_column_type IN (1)    AND INP_Object_Columns.ColumnName IS NOT NULL THEN 1
                        ELSE 0
                     END)
                ) AS TCE_tech_column_in_INP_Object
            ,SUM(
                    (CASE
                        WHEN XXY.GCFR_tech_column_type = 1 AND OUT_Object_Columns.ColumnName IS NOT NULL THEN 1
                        ELSE 0
                     END)
                ) AS num_tech_column_in_OUT_Object
            ,SUM(
                    (CASE
                        WHEN x01.Process_Type IN (13,14,17,18,20,41,42,43,44) AND OUT_Object_Columns.ColumnName IS NOT NULL AND Target_Table_Columns.ColumnName IS NULL THEN 1
                        WHEN x01.Process_Type IN (13,14,17,18,20,41,42,43,44) AND OUT_Object_Columns.ColumnName IS NULL AND Target_Table_Columns.ColumnName IS NOT NULL THEN 1
                        ELSE 0
                     END)
                ) AS TCE_OUT_Target_Diff
            ,SUM(
                    (CASE
                        WHEN XXY.GCFR_tech_column_type > 0 THEN 0
                        WHEN x01.Process_Type IN (23,24,25) AND INP_Object_Columns.ColumnName IS NOT NULL AND OUT_Object_Columns.ColumnName IS NULL THEN 1
                        WHEN x01.Process_Type IN (23,24,25) AND INP_Object_Columns.ColumnName IS NULL AND OUT_Object_Columns.ColumnName IS NOT NULL THEN 1
                        ELSE 0
                     END)
                ) AS TCE_INP_OUT_Diff
            ,SUM(
                    (CASE
                        WHEN XXY.GCFR_tech_column_type > 0 THEN 0
                        WHEN x01.Process_Type IN (23,24,25) AND Target_Table_Columns.Nullable = 'N' AND Target_Table_Columns.DefaultValue IS NULL AND OUT_Object_Columns.ColumnName IS NULL THEN 1
                        WHEN x01.Process_Type IN (23,24,25) AND Target_Table_Columns.ColumnName IS NULL AND (INP_Object_Columns.ColumnName IS NOT NULL OR OUT_Object_Columns.ColumnName IS NOT NULL) THEN 1
                        ELSE 0
                     END)
                ) AS TCE_in_Target
            ,SUM(
                    (CASE
                        WHEN x01.Process_Type IN (23,24,25) AND Transform_KeyCol.Key_column IS NOT NULL AND Target_Table_Columns.ColumnName IS NOT NULL AND OUT_Object_Columns.ColumnName IS NOT NULL AND Target_Table_Columns.Nullable = 'N' THEN 0 -- OK
                        WHEN x01.Process_Type IN (23,24,25) AND Transform_KeyCol.Key_column IS NULL THEN 0 -- OK
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
            ,SUM(
                    (CASE
                        WHEN x01.Process_Type IN (23,24,25) AND Transform_KeyCol.Key_column IS NULL AND Target_Table_PI_Columns.ColumnName IS NOT NULL THEN 1
                        ELSE 0
                     END)
                ) AS PI_Transform_KeyCol_Diff

        FROM <GCFR_V>.GCFR_Process AS x01

        JOIN
            (
                -- generate list of all columns (INP, OUT, Target) related to that process
                SELECT y01.Process_Name, y02.ColumnName
                      ,CAST((CASE
                                WHEN y02.ColumnName IN ('Start_Date', 'End_Date', 'Start_Ts', 'End_Ts', 'Record_Deleted_Flag', 'Ctl_Id', 'Process_Name', 'Process_Id', 'Update_Process_Name', 'Update_Process_Id') THEN 1
                                WHEN y02.ColumnName IN ('GCFR_Delta_Action_Code') THEN 2
                                ELSE 0
                            END) AS BYTEINT) AS GCFR_tech_column_type
                  FROM <GCFR_V>.GCFR_Process AS y01
                  JOIN DBC.ColumnsV AS y02
                    ON y02.DatabaseName = y01.In_DB_Name
                   AND y02.TableName    = y01.In_Object_Name
                 UNION
                SELECT y03.Process_Name, y04.ColumnName
                      ,CAST((CASE
                                WHEN y04.ColumnName IN ('Start_Date', 'End_Date', 'Start_Ts', 'End_Ts', 'Record_Deleted_Flag', 'Ctl_Id', 'Process_Name', 'Process_Id', 'Update_Process_Name', 'Update_Process_Id') THEN 1
                                WHEN y04.ColumnName IN ('GCFR_Delta_Action_Code') THEN 2
                                ELSE 0
                            END) AS BYTEINT) AS GCFR_tech_column_type
                  FROM <GCFR_V>.GCFR_Process AS y03
                  JOIN DBC.ColumnsV AS y04
                    ON y04.DatabaseName = y03.Out_DB_Name
                   AND y04.TableName    = y03.Out_Object_Name
                 UNION
                SELECT y05.Process_Name, y06.ColumnName
                      ,CAST((CASE
                                WHEN y06.ColumnName IN ('Start_Date', 'End_Date', 'Start_Ts', 'End_Ts', 'Record_Deleted_Flag', 'Ctl_Id', 'Process_Name', 'Process_Id', 'Update_Process_Name', 'Update_Process_Id') THEN 1
                                WHEN y06.ColumnName IN ('GCFR_Delta_Action_Code') THEN 2
                                ELSE 0
                            END) AS BYTEINT) AS GCFR_tech_column_type
                  FROM <GCFR_V>.GCFR_Process AS y05
                  JOIN DBC.ColumnsV AS y06
                    ON y06.DatabaseName = y05.Target_TableDatabaseName
                   AND y06.TableName    = y05.Target_TableName
                 UNION
                SELECT y07.Process_Name, y08.Key_Column
                      ,CAST((CASE
                                WHEN y08.Key_Column IN ('Start_Date', 'End_Date', 'Start_Ts', 'End_Ts', 'Record_Deleted_Flag', 'Ctl_Id', 'Process_Name', 'Process_Id', 'Update_Process_Name', 'Update_Process_Id') THEN 1
                                WHEN y08.Key_Column IN ('GCFR_Delta_Action_Code') THEN 2
                                ELSE 0
                            END) AS BYTEINT) AS GCFR_tech_column_type
                  FROM <GCFR_V>.GCFR_Process AS y07
                  JOIN <GCFR_V>.GCFR_Transform_KeyCol AS y08
                    ON y08.Out_DB_Name     = y07.Out_DB_Name
                   AND y08.Out_Object_Name = y07.Out_Object_Name
            ) AS XXY
        ON x01.Process_Name = XXY.Process_Name

        LEFT JOIN DBC.ColumnsV AS INP_Object_Columns
          ON INP_Object_Columns.DatabaseName = x01.In_DB_Name
         AND INP_Object_Columns.TableName    = x01.In_Object_Name
         AND INP_Object_Columns.ColumnName   = XXY.ColumnName

        LEFT JOIN DBC.ColumnsV AS OUT_Object_Columns
          ON OUT_Object_Columns.DatabaseName = x01.Out_DB_Name
         AND OUT_Object_Columns.TableName    = x01.Out_Object_Name
         AND OUT_Object_Columns.ColumnName   = XXY.ColumnName

        LEFT JOIN DBC.ColumnsV AS Target_Table_Columns
          ON Target_Table_Columns.DatabaseName = x01.Target_TableDatabaseName
         AND Target_Table_Columns.TableName    = x01.Target_TableName
         AND Target_Table_Columns.ColumnName   = XXY.ColumnName

        LEFT JOIN <GCFR_V>.GCFR_Transform_KeyCol AS Transform_KeyCol
          ON Transform_KeyCol.out_db_name     = x01.Out_DB_Name
         AND Transform_KeyCol.out_object_name = x01.Out_Object_Name
         AND Transform_KeyCol.Key_column      = XXY.ColumnName

        LEFT JOIN DBC.indicesv AS Target_Table_PI_Columns
          ON Target_Table_PI_Columns.DatabaseName = x01.Target_TableDatabaseName
         AND Target_Table_PI_Columns.TableName    = x01.Target_TableName
         AND Target_Table_PI_Columns.ColumnName   = XXY.ColumnName
         AND Target_Table_PI_Columns.IndexType    IN ('P', 'O')

        GROUP BY 1
    ) AS Column_Errors
ON Column_Errors.Process_Name = processes.Process_Name

LEFT JOIN
    (
        SELECT Process_Name, COUNT(*) AS Num_of_System_Files
        FROM <GCFR_V>.GCFR_File_Process AS t01
        JOIN <GCFR_V>.GCFR_System_File AS t02
        ON t01.File_Id = t02.File_Id
        GROUP BY 1
    ) AS System_File
ON System_File.Process_Name = processes.Process_Name

LEFT JOIN <UTL_V>.BKEY_Key_Set AS Key_Set
ON Key_Set.Key_Set_Id = processes.Key_Set_Id

LEFT JOIN
    (
        SELECT TRIM(DatabaseName) AS DatabaseName, TRIM(TableName) AS TableName, TableKind
        FROM DBC.TablesV
    ) AS BKEY_Key_Map_Table
ON BKEY_Key_Map_Table.DatabaseName = Key_Set.Key_Table_DB_Name
AND BKEY_Key_Map_Table.TableName = Key_Set.Key_Table_Name

LEFT JOIN <UTL_V>.BKEY_Domain AS Key_Domain
ON Key_Domain.Key_Set_Id = processes.Key_Set_Id
AND Key_Domain.Domain_Id = processes.Domain_Id

LEFT JOIN <UTL_V>.BMAP_Code_Set AS Code_Set
ON Code_Set.Code_Set_Id = processes.Code_Set_Id

LEFT JOIN
    (
        SELECT TRIM(DatabaseName) AS DatabaseName, TRIM(TableName) AS TableName, TableKind
        FROM DBC.TablesV
    ) AS BMAP_Code_Map_Table
ON BMAP_Code_Map_Table.DatabaseName = Code_Set.Map_Table_DB_Name
AND BMAP_Code_Map_Table.TableName = Code_Set.Map_Table_Name

LEFT JOIN <UTL_V>.BMAP_Domain AS Code_Domain
ON Code_Domain.Code_Set_Id = processes.Code_Set_Id
AND Code_Domain.Domain_Id = processes.Domain_Id

LEFT JOIN <GCFR_V>.GCFR_Stream_Id AS Open_Stream
ON Open_Stream.Stream_Key = processes.Stream_Key

LEFT JOIN <GCFR_V>.GCFR_Stream_BusDate AS Open_Stream_BusDate
ON Open_Stream_BusDate.Stream_Key = processes.Stream_Key

WHERE processes.Process_Type IN (13, 14, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 29, 30, 32, 35, 40, 41, 42, 43, 44)
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
comment on column <GCFR_V>.Check_GCFR_Processes.Status_Stream_BusDate is 'Status of the BusinessDate for the Stream (Started, Ended)';
comment on column <GCFR_V>.Check_GCFR_Processes.Status_Stream is 'Status of the Stream within the BusinessDate (Started, Ended)';
comment on column <GCFR_V>.Check_GCFR_Processes.Business_Date is 'Current BusinessDate';
comment on column <GCFR_V>.Check_GCFR_Processes.Business_Date_Cycle_Start_TS is 'Current Cycle Start';
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
comment on column <GCFR_V>.Check_GCFR_Processes.TCE_in_Transform_KeyCol is 'Transform Column Error: no Columns defined as Key in GCFR_Transform_KeyCol or defined Key does not exist as column in Target Table or column is NULLABLE in Target Table';
comment on column <GCFR_V>.Check_GCFR_Processes.TCE_in_Process_Type is 'Transform Column Error: Process_Type is defined as delta, but missing column GCFR_Delta_Action_Code or vice versa';
comment on column <GCFR_V>.Check_GCFR_Processes.TCE_in_Tech_Columns is 'Transform Column Error: Too few GCFR technical columns depending on Stream-Cycle-Frequency-Code';
comment on column <GCFR_V>.Check_GCFR_Processes.Sum_TCE is 'Summarize all TCE* columns to show errors (easy to order in result set), a value greater then zero will very likely cause an abort in the GCFR process';
comment on column <GCFR_V>.Check_GCFR_Processes.Fail_Indicator is 'Summarize all TCE* columns plus File and BKEY/BMAP status, a value greater then zero will very likely cause an abort in the GCFR process';
comment on column <GCFR_V>.Check_GCFR_Processes.PI_Transform_KeyCol_Mismatch is 'Value greater than 0 means Target Table has column in PI which is not used as Transform_KeyCol (technically no error, but inefficient query)';
