REPLACE PROCEDURE $GCFR_P_UT.GCFR_UT_BKEY_Register_New
/*====================================================================================================
# Purpose:     GCFR_UT_Register_new_BKEY
#                    delete and insert into BKEY_Key_Set new Key_Set_Id
#                    create <Key_Table_Name> table if not exist with given name in <T_DB> database
#                    replace <Key_Table_Name> view in <V_DB> if not exist
#                    create <Key_Table_Name>_Next_Id table if not exist with given name in $UTL_T database
#                    replace <Key_Table_Name>_Next_Id view in $UTL_V if not exist
#                    create <Key_Table_Name>_Next_Id_Log table if not exist with given name in $UTL_T database
#                    replace <Key_Table_Name>_Next_Id_Log view in $UTL_V if not exist
#                    create update and insert triggers if not exist for _Next_Id_Log table
#                    insert intitial record for Key_Set_Id into <Key_Table_Name>_Next_Id
#
# Comments:   OMessage - Formatted message
#
# History:
# Created By:  Andreas Wenzel (aw230056) 20015-10-15
#   Description: New code
======================================================================================================*/
/* Stored Procedure Parameters */
    (
         IN iKey_Set_Id                    SMALLINT
        ,IN iDescription                   VARCHAR(240)
        ,IN iTableDatabaseName             VARCHAR(128)
        ,IN iViewDatabaseName              VARCHAR(128)
        ,IN iKey_Table_Name                VARCHAR(116)
        ,IN iBIGINT_Flag                   BYTEINT
        ,IN iIndividual_Next_Id_Table_Flag BYTEINT
        ,OUT OMessage                      VARCHAR(1000)
    )

MAIN:
BEGIN

    DECLARE vSQL_Text               VARCHAR(10000);
    DECLARE vCount1                 INTEGER DEFAULT 0;
    DECLARE vCount2                 INTEGER DEFAULT 0;
    DECLARE vMessage                VARCHAR(1000) DEFAULT '';

    DECLARE vKey_Table_Name         VARCHAR(150);
    DECLARE vNext_Id_Table_Name     VARCHAR(150);
    DECLARE vNext_Id_Log_Table_Name VARCHAR(150);

    SET vKey_Table_Name         = TRIM(iKey_Table_Name);
    SET vNext_Id_Table_Name     = TRIM(iKey_Table_Name) || '_Next_Id';
    SET vNext_Id_Log_Table_Name = TRIM(iKey_Table_Name) || '_Next_Id_Log';


    /***********************************************************************/
    /* Delete and insert new row in BKEY_Key_Set table                     */
    /***********************************************************************/
    BEGIN TRANSACTION;

        DELETE FROM $UTL_V.BKEY_Key_Set
        WHERE Key_Set_Id = :iKey_Set_Id;

        INSERT INTO $UTL_V.BKEY_Key_Set
            (
                 Key_Set_Id
                ,Description
                ,Key_Table_Name
                ,Key_Table_DB_Name
                ,Update_Date
                ,Update_User
                ,Update_Ts
            )
        VALUES
            (
                 :iKey_Set_Id           -- Key_Set_Id
                ,:iDescription          -- Description
                ,:iKey_Table_Name       -- Key_Table_Name
                ,:iViewDatabaseName     -- Key_Table_DB_Name
                ,DATE                   -- Update_Date
                ,USER                   -- Update_User
                ,&&CURRENT_TS_TYPE&&    -- Update_Ts
            );

    END TRANSACTION;


    /***********************************************************************/
    /* Create new BKEY_Standard_Key table if not exists                    */
    /*  as <KEY_TABLE_NAME> in iTableDatabaseName                          */
    /***********************************************************************/
    SELECT COUNT(*)
      INTO :vCount1
      FROM DBC.TablesV
     WHERE DATABASENAME = :iTableDatabaseName
       AND TABLENAME = :vKey_Table_Name;

    /* Build and execute Create Table command if appropriate*/
    IF vCount1 <> 0 THEN
       SET vMessage = vMessage || TRIM(iTableDatabaseName) || '.' || vKey_Table_Name || ' table already exist. Skipping table generation.
';
    ELSE

        SET vSQL_Text='CREATE MULTISET TABLE ' || TRIM(iTableDatabaseName) || '.' || vKey_Table_Name || ' ,NO FALLBACK ,
                NO BEFORE JOURNAL,
                NO AFTER JOURNAL,
                CHECKSUM = DEFAULT
            (
                  Source_Key               VARCHAR(255) NOT NULL
                , Domain_Id                SMALLINT NOT NULL
                , Key_Set_Id               SMALLINT NOT NULL
                , EDW_Key ';

        IF iBIGINT_Flag = 1 THEN
            SET vSQL_Text = vSQL_Text || ' BIGINT ';
        ELSE
            SET vSQL_Text = vSQL_Text || ' INTEGER ';
        END IF;

        SET vSQL_Text = vSQL_Text || '  NOT NULL
                , Start_Date               DATE NOT NULL &&DATE_FORMAT1&&
                , End_Date                 DATE NOT NULL &&DATE_FORMAT1&& DEFAULT &&HIGH_DATE1&&
                , Record_Deleted_Flag      BYTEINT NOT NULL DEFAULT 0 COMPRESS (0, 1)
                , Ctl_Id                   SMALLINT NOT NULL
                , Process_Name             VARCHAR(30) NOT NULL
                , Process_Id               INTEGER NOT NULL
                , Update_Process_Name      VARCHAR(30)
                , Update_Process_Id        INTEGER
            )
                PRIMARY INDEX ( Source_Key, Domain_Id, Key_Set_Id )';

        CALL DBC.SysExecSQL(:vSQL_Text);

        SET vMessage = vMessage || TRIM(iTableDatabaseName) || '.' || vKey_Table_Name || ' table generated.
';

    END IF;


    /***********************************************************************/
    /* Create new BKEY_Standard_Key view if table exists                   */
    /*  as <KEY_TABLE_NAME> in :iTableDatabaseName                         */
    /*  and view does not exist in :iViewDatabaseName                      */
    /***********************************************************************/
    SELECT COUNT(*)
      INTO :vCount1
      FROM DBC.TablesV
     WHERE DATABASENAME = :iTableDatabaseName
       AND TABLENAME = :vKey_Table_Name;

    SELECT COUNT(*)
      INTO :vCount2
      FROM DBC.TablesV
     WHERE DATABASENAME = :iViewDatabaseName
       AND TABLENAME = :vKey_Table_Name;

    /* Build and execute Create view command if appropriate */
    IF vCount1 = 1 AND vCount2 = 0 THEN

        SET vSQL_Text = 'REPLACE VIEW ' || TRIM(iViewDatabaseName) || '.' || vKey_Table_Name || '
            AS
            LOCKING ROW FOR ACCESS
            SELECT
                  Source_Key
                , Domain_Id
                , Key_Set_Id
                , EDW_Key
                , Start_Date
                , End_Date
                , Record_Deleted_Flag
                , Ctl_Id
                , Process_Name
                , Process_Id
                , Update_Process_Name
                , Update_Process_Id
            FROM ' || TRIM(iTableDatabaseName) || '.' || vKey_Table_Name;

        CALL DBC.SysExecSQL(:vSQL_Text);

        SET vMessage = vMessage || TRIM(iViewDatabaseName) || '.' || vKey_Table_Name || ' view generated.
';
    ELSE
        IF vCount1 = 1 AND vCount2 = 1 THEN
            SET vMessage = vMessage || TRIM(iViewDatabaseName) || '.' || vKey_Table_Name || ' view not generated because view exists.
';
        ELSE
            IF vCount1 = 0 AND vCount2 = 1 THEN
                SET vMessage = vMessage || TRIM(iViewDatabaseName) || '.' || vKey_Table_Name || ' view not generated because table does not exist but view exists.
';
            ELSE
                IF vCount1 = 0 AND vCount2 = 0 THEN
                    SET vMessage = vMessage || TRIM(iViewDatabaseName) || '.' || vKey_Table_Name || ' view not generated because table does not exist.
';
                ELSE
                    SET vMessage = vMessage || TRIM(iViewDatabaseName) || '.' || vKey_Table_Name || ' view not generated because unknown error encountered (too many objects found??).
';
                END IF;
            END IF;
        END IF;
    END IF;


    /***********************************************************************/
    /* If to create individual next_Id tables or not                       */
    /***********************************************************************/
    if iIndividual_Next_Id_Table_Flag <> 1 THEN
        SET vMessage = vMessage || ' The option "iIndividual_Next_Id_Table_Flag <> 1" is not supported yet by BKEY processes! Proceeding as usual.
';
    END IF;

    /***********************************************************************/
    /* Create new BKEY_Standard_Key_Next_Id table if not exists            */
    /*  as <KEY_TABLE_NAME>_Next_Id in $UTL_T database                     */
    /***********************************************************************/
    SELECT COUNT(*)
      INTO :vCount1
      FROM DBC.TablesV
     WHERE DATABASENAME = '$UTL_T'
       AND TABLENAME = :vNext_Id_Table_Name;

    /* Build and execute Create Table command if appropriate */
    IF vCount1 <> 0 THEN
        SET vMessage = vMessage || '$UTL_T.' || vNext_Id_Table_Name || ' table already exist. Skipping table generation.
';
    ELSE
        SET vSQL_Text = 'CREATE SET TABLE $UTL_T.' || vNext_Id_Table_Name || ' ,NO FALLBACK ,
                NO BEFORE JOURNAL,
                NO AFTER JOURNAL,
                CHECKSUM = DEFAULT
            (
                Key_Set_Id   SMALLINT NOT NULL,
                Next_EDW_Key ';

        IF iBIGINT_Flag = 1 THEN
            SET vSQL_Text = vSQL_Text || ' BIGINT ';
        ELSE
            SET vSQL_Text = vSQL_Text || ' INTEGER ';
        END IF;

        SET vSQL_Text = vSQL_Text || ' NOT NULL DEFAULT 1 ,
                Update_Date  DATE NOT NULL &&DATE_FORMAT1&& DEFAULT DATE ,
                Update_User  VARCHAR(30) CHARACTER SET UNICODE NOT CASESPECIFIC NOT NULL DEFAULT USER ,
                Update_Ts    &&TS_TYPE&& NOT NULL DEFAULT &&CURRENT_TS_TYPE&&
            )
                UNIQUE PRIMARY INDEX ( Key_Set_Id )';

        CALL DBC.SysExecSQL(:vSQL_Text);

        SET vMessage = vMessage || '$UTL_T.' || vNext_Id_Table_Name || ' table generated.
';

    END IF;


    /***********************************************************************/
    /* Create new BKEY_Standard_Key_Next_Id view if table exists           */
    /*  as <KEY_TABLE_NAME>_Next_Id in $UTL_T                              */
    /*  and view does not exist in $UTL_V                                  */
    /***********************************************************************/
    SELECT COUNT(*)
      INTO :vCount1
      FROM DBC.TablesV
     WHERE DATABASENAME = '$UTL_T'
       AND TABLENAME = :vNext_Id_Table_Name;

    SELECT COUNT(*)
      INTO :vCount2
      FROM DBC.TablesV
     WHERE DATABASENAME = '$UTL_V'
       AND TABLENAME = :vNext_Id_Table_Name;

    /* Build and execute Create view command if appropriate*/
    IF vCount1 = 1 AND vCount2 = 0 THEN

        SET vSQL_Text='REPLACE VIEW $UTL_V.' || vNext_Id_Table_Name || '
            AS
            LOCKING ROW FOR ACCESS
            SELECT
                     Key_Set_Id
                    ,Next_EDW_Key
                    ,Update_Date
                    ,Update_User
                    ,Update_Ts
            FROM  $UTL_T.' || vNext_Id_Table_Name;

        CALL DBC.SysExecSQL(:vSQL_Text);

        SET vMessage = vMessage || '$UTL_V.' || vNext_Id_Table_Name || ' view generated.
';

    ELSE
        IF vCount1 = 1 AND vCount2 = 1 THEN
            SET vMessage = vMessage || TRIM(iViewDatabaseName) || '.' || vNext_Id_Table_Name || ' view not generated because view exists.
';
        ELSE
            IF vCount1 = 0 AND vCount2 = 1 THEN
                SET vMessage = vMessage || TRIM(iViewDatabaseName) || '.' || vNext_Id_Table_Name || ' view not generated because table does not exist but view exists.
';
            ELSE
                IF vCount1 = 0 AND vCount2 = 0 THEN
                    SET vMessage = vMessage || TRIM(iViewDatabaseName) || '.' || vNext_Id_Table_Name || ' view not generated because table does not exist.
';
                ELSE
                    SET vMessage = vMessage || TRIM(iViewDatabaseName) || '.' || vNext_Id_Table_Name || ' view not generated because unknown error encountered (too many objects found??).
';
                END IF;
            END IF;
        END IF;
    END IF;


    /***********************************************************************/
    /* Create new BKEY_Standard_Key_Next_Id_Log table if not exists        */
    /*  as <KEY_TABLE_NAME>_Next_Id_Log in $UTL_T database                 */
    /***********************************************************************/
    SELECT COUNT(*)
      INTO :vCount1
      FROM DBC.TablesV
     WHERE DATABASENAME = '$UTL_T'
       AND TABLENAME = :vNext_Id_Log_Table_Name;

    /* Build and execute Create Table command if appropriate*/
    IF vCount1 <> 0 THEN
       SET vMessage = vMessage || '$UTL_T.' || vNext_Id_Log_Table_Name || ' table already exist. Skipping table generation.
';
    ELSE
        SET vSQL_Text='CREATE MULTISET TABLE $UTL_T' || '.' || vNext_Id_Log_Table_Name || ' ,NO FALLBACK ,
                NO BEFORE JOURNAL,
                NO AFTER JOURNAL,
                CHECKSUM = DEFAULT
            (
                Key_Set_Id   SMALLINT NOT NULL,
                Next_EDW_Key ';
        IF iBIGINT_Flag = 1 THEN
            SET vSQL_Text = vSQL_Text || ' BIGINT ';
        ELSE
            SET vSQL_Text = vSQL_Text || ' INTEGER ';
        END IF;
        SET vSQL_Text = vSQL_Text || '   NOT NULL DEFAULT 1 ,
                    Update_Date  DATE NOT NULL &&DATE_FORMAT1&& DEFAULT DATE ,
                    Update_User  VARCHAR(30) CHARACTER SET UNICODE NOT CASESPECIFIC NOT NULL DEFAULT USER ,
                    Update_Ts    &&TS_TYPE&& NOT NULL DEFAULT &&CURRENT_TS_TYPE&&
                )
                    PRIMARY INDEX ( Key_Set_Id );';

        CALL DBC.SysExecSQL(:vSQL_Text);

        /* CREATE TI_<Key_Table_Name>_Next_Id INSERT TRIGGER */
        SET vSQL_Text='REPLACE TRIGGER $UTL_T' || '.TI_' || vNext_Id_Table_Name || '
            AFTER INSERT ON $UTL_T' || '.' || vNext_Id_Table_Name || '
            REFERENCING NEW ROW AS n
            FOR EACH ROW  (
            INSERT INTO $UTL_T.' || vNext_Id_Log_Table_Name || ' (
                  Key_Set_Id
                , Next_EDW_Key
                , Update_Date
                , Update_User
                , Update_Ts
            ) VALUES (
                  n.Key_Set_Id
                , n.Next_EDW_Key
                , n.Update_Date
                , n.Update_User
                , n.Update_Ts
                );
            )';

        CALL DBC.SysExecSQL(:vSQL_Text);

        /* CREATE TU_<Key_Table_Name>_Next_Id UPDATE TRIGGER */
        SET vSQL_Text='REPLACE TRIGGER $UTL_T' || '.TU_' || vNext_Id_Table_Name || '
            AFTER UPDATE ON $UTL_T' || '.' || vNext_Id_Table_Name || '
            REFERENCING NEW ROW AS n
            FOR EACH ROW  (
            INSERT INTO $UTL_T.' || vNext_Id_Log_Table_Name || ' (
                  Key_Set_Id
                , Next_EDW_Key
                , Update_Date
                , Update_User
                , Update_Ts
            ) VALUES (
                  n.Key_Set_Id
                , n.Next_EDW_Key
                , n.Update_Date
                , n.Update_User
                , n.Update_Ts
                );
            )';
        CALL DBC.SysExecSQL(:vSQL_Text);

        SET vMessage = vMessage || vNext_Id_Log_Table_Name || ' Table, TI_' || vNext_Id_Table_Name || ' & TU_' || vNext_Id_Table_Name || ' Trigger generated.
';
    END IF;


    /***********************************************************************/
    /* Create new BKEY_Standard_Key_Next_Id view if table exists           */
    /*  as <KEY_TABLE_NAME>_Next_Id in $UTL_T                              */
    /*  and view does not exist in $UTL_V                                  */
    /***********************************************************************/
    SELECT COUNT(*)
      INTO :vCount1
      FROM DBC.TablesV
     WHERE DATABASENAME = '$UTL_T'
       AND TABLENAME = :vNext_Id_Log_Table_Name;

    SELECT COUNT(*)
      INTO :vCount2
      FROM DBC.TablesV
     WHERE DATABASENAME = '$UTL_V'
       AND TABLENAME = :vNext_Id_Log_Table_Name;

    IF vCount1 = 1 AND vCount2 = 0 THEN

        /* Build and execute Create view command if appropriate*/
        SET vSQL_Text='REPLACE VIEW $UTL_V.' || vNext_Id_Log_Table_Name || '
            AS
            LOCKING ROW FOR ACCESS
            SELECT
                     Key_Set_Id
                    ,Next_EDW_Key
                    ,Update_Date
                    ,Update_User
                    ,Update_Ts
            FROM $UTL_T.' || vNext_Id_Log_Table_Name;

        CALL DBC.SysExecSQL(:vSQL_Text);

        SET vMessage = vMessage || '$UTL_V.' || vNext_Id_Log_Table_Name || ' view generated.
';
    ELSE
        IF vCount1 = 1 AND vCount2 = 1 THEN
            SET vMessage = vMessage || TRIM(iViewDatabaseName) || '.' || vNext_Id_Log_Table_Name || ' view not generated because view exists.
';
        ELSE
            IF vCount1 = 0 AND vCount2 = 1 THEN
                SET vMessage = vMessage || TRIM(iViewDatabaseName) || '.' || vNext_Id_Log_Table_Name || ' view not generated because table does not exist but view exists.
';
            ELSE
                IF vCount1 = 0 AND vCount2 = 0 THEN
                    SET vMessage = vMessage || TRIM(iViewDatabaseName) || '.' || vNext_Id_Log_Table_Name || ' view not generated because table does not exist.
';
                ELSE
                    SET vMessage = vMessage || TRIM(iViewDatabaseName) || '.' || vNext_Id_Log_Table_Name || ' view not generated because unknown error encountered (too many objects found??).
';
                END IF;
            END IF;
        END IF;
    END IF;


    /***********************************************************************/
    /* Insert prime record for Key_Set_Id into Next_Id table               */
    /***********************************************************************/
    SELECT COUNT(*)
      INTO :vCount1
      FROM DBC.TablesV
     WHERE DATABASENAME = '$UTL_T'
       AND TABLENAME = :vNext_Id_Table_Name;

    SELECT COUNT(*)
      INTO :vCount2
      FROM DBC.TablesV
     WHERE DATABASENAME = '$UTL_V'
       AND TABLENAME = :vNext_Id_Table_Name;

    IF vCount1 = 1 AND vCount2 = 1 THEN

        SET vSQL_Text = 'DELETE FROM $UTL_V.' || vNext_Id_Table_Name || ' WHERE Key_Set_Id = ' || iKey_Set_Id;

        BEGIN TRANSACTION;
            CALL DBC.SysExecSQL(:vSQL_Text);

            SET vSQL_Text = 'INSERT INTO $UTL_V.' || vNext_Id_Table_Name || '
                (     Key_Set_Id
                    , Next_EDW_Key
                    , Update_Date
                    , Update_User
                    , Update_Ts
                )
                SELECT
                      ' || iKey_Set_Id || '   AS Key_Set_Id
                    , (SELECT COALESCE(MAX(EDW_Key) + 1, 1) FROM ' || TRIM(iViewDatabaseName) || '.' || iKey_Table_Name || ' WHERE Key_Set_Id = ' || iKey_Set_Id || ') AS Next_EDW_Key
                    , DATE                AS Update_Date
                    , USER                AS Update_User
                    , &&CURRENT_TS_TYPE&&   AS Update_Ts';

            CALL DBC.SysExecSQL(:vSQL_Text);

        END TRANSACTION;

        SET vMessage = vMessage || 'Priming row in the table $UTL_T.' || vNext_Id_Table_Name || ' generated.';
    ELSE
        SET vMessage = vMessage || '$UTL_T.' || vNext_Id_Table_Name || ' table doesn''t exist. Skipping priming row generation.';
    END IF;

    SET OMessage = vMessage;

END MAIN;
