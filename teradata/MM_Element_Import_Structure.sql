-- #########################################################################
--     MM_Element_Import_Structure.sql
--     Copyright (C) 2015  Andreas Wenzel (https://github.com/tdawen)
--
--     This program is free software: you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation, either version 3 of the License, or
--     (at your option) any later version.
--
--     This program is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
--
--     You should have received a copy of the GNU General Public License
--     along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- #########################################################################


SELECT
    TRIM(TABLENAME) AS "DATA_STRUCTURE_NAME_DE5.0"
    ,TRIM(columnname) AS "DATA_ELEMENT_NAME"
    ,COALESCE(CommentString,'') AS "DATA_ELEMENT_DESC"
    ,'' AS "LoadColumnName_TMM"
    ,ROW_NUMBER() OVER (PARTITION BY databasename, TABLENAME ORDER BY columnid) AS "ColumnOrder_TMM"
    ,'VARCHAR('||data_leng AS "StgType_TMM"
    ,'' AS "SrcIType_TMM"
    ,'' AS "TransformKey_TMM"
    ,'' AS "SrcIPI_TMM"
    ,'' AS "StgPI_TMM"
    ,'' AS "CharacterSet_TMM"
    ,'' AS "Nullable_TMM"
    ,'' AS "NullBlank_TMM"
    ,TRIM((CASE
        WHEN columntype = 'CV' THEN 6
        WHEN columntype = 'CF' THEN 4
        WHEN columntype = 'DA' THEN 2
        WHEN columntype IN ('I', 'I1', 'I2', 'I4', 'I8') THEN 8
        WHEN columntype = 'TS' THEN 3
        WHEN columntype IN ('N', 'D') THEN 5
        WHEN columntype = 'T' THEN 7
        ELSE ''
     END)) AS "DATA_TYPE_CD"
    ,TRIM((CASE
        WHEN columntype IN ('CF', 'CV') THEN ColumnLength / CharType
        WHEN columntype IN ('D', 'N') THEN DecimalTotalDigits
        ELSE ''
     END)) AS "DATA_ELEMENT_LENGTH_INT"
    ,TRIM((CASE
        WHEN columntype IN ('D', 'N') THEN decimalFractionalDigits
        ELSE ''
     END)) AS "DATA_ELEMENT_PRECISION_INT"
    ,CAST(2 AS BYTEINT) AS "DATA_ELEMENT_TYPE_CD"
    ,Nullable AS "NULL_OPTION_IND"
    ,ROW_NUMBER() OVER (PARTITION BY databasename, TABLENAME ORDER BY columnid) AS "LOGICAL_SEQUENCE_NUMBER"
    ,ROW_NUMBER() OVER (PARTITION BY databasename, TABLENAME ORDER BY columnid) AS "PHYSICAL_SEQUENCE_NUMBER"
    ,'' AS "PLACEHOLDER_TYPE_CD"
FROM dbc.columnsv
WHERE databasename = 'GDEV1T_STG'
ORDER BY databasename, TABLENAME, ColumnName
;
