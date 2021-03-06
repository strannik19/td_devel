-- #########################################################################
--     read_dd4Table_Definition.sql
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


--
-- Select table information and column information (for import into Excel)
-- change WHERE condition of databasename
-- The output format is for my Excel document to document the physical
-- table definition in the database
--

select trim(t01.TableName) TableName
	,case when t01.CheckOpt = 'N' then 'SET' when t01.CheckOpt = 'Y' then 'MULTISET' end TableType
	,case when t01.Commentstring is null then '' else trim(t01.CommentString) end CommentString
	,case when t01.TableKind = 'O' then 'yes' else '' end "no PI Table"
	,case when t02.IndexName is null then '' else t02.Indexname end PI_Name
from dbc.tables t01
left join (select databasename, tablename, IndexName from dbc.indices where indextype = 'P' group by databasename, tablename, IndexName) t02
on t01.databasename = t02.databasename
and t01.tablename = t02.tablename
where t01.databasename = <DATABASE_NAME>;

-- Does not support PPI at the moment
-- Still some datatypes missing
select trim(t01.TableName) TableName
	,trim(t03.ColumnName) ColumnName
	,row_number() over (partition by t01.databasename, t01.tablename order by t03.ColumnId) "Pos"
	,'' PrimaryKey
	,case when t02.ColumnName is not null and t02.UniqueFlag = 'N' then 'NUPI'
	      when t02.ColumnName is not null and t02.UniqueFlag = 'Y' then 'UPI'
	      else ''
	 end "PI"
	,'' "PPI"
	,t03.ColumnType "Datatype ori"
	,case when t03.ColumnType = 'DA' then 'DATE'
	      when t03.ColumnType = 'AT' and t03.ColumnLength = 8 then 'TIME(0)'
	      when t03.ColumnType = 'AT' and t03.ColumnLength > 8 then 'TIME('||trim(t03.ColumnLength-9)||')'
	      when t03.ColumnType = 'TS' and t03.ColumnLength = 19 then 'TIMESTAMP(0)'
	      when t03.ColumnType = 'TS' and t03.ColumnLength > 19 then 'TIMESTAMP('||trim(t03.ColumnLength-20)||')'
	      when t03.ColumnType = 'CF' then 'CHAR'||'('||trim(t03.ColumnLength)||')'
	      when t03.ColumnType = 'CV' then 'VARCHAR'||'('||trim(t03.ColumnLength)||')'
	      when t03.ColumnType = 'I'  then 'INTEGER'
	      when t03.ColumnType = 'I1' then 'BYTEINT'
	      when t03.ColumnType = 'I2' then 'SMALLINT'
	      when t03.ColumnType = 'I8' then 'BIGINT'
	      when t03.ColumnType = 'D' and t03.DecimalTotalDigits is not null and t03.DecimalFractionalDigits is not null then 'DECIMAL('||trim(t03.DecimalTotalDigits)||','||trim(t03.DecimalFractionalDigits)||')'
	 end "Datatype TD"
	,'' as "CharacterSet"
	,'' as "Casespecific"
	,case when t03.Nullable = 'N' then 'yes' else 'no' end "Required"
	,case when t03.ColumnType = 'DA' then t03.ColumnFormat else '' end "Format"
	,case when t03.DefaultValue is null then '' else t03.DefaultValue end "Default Value"
	,case when t03.CommentString is null then '' else t03.CommentString end "Comment"
	,'' "Synthethic by DWH"
	,'' "PPI Definition"
from dbc.tables t01
join dbc.columns t03
on t01.databasename = t03.databasename
and t01.tablename = t03.tablename
left join dbc.indices t02
on t01.databasename = t02.databasename
and t01.tablename = t02.tablename
and t02.IndexType = 'P'
and t02.columnname = t03.columnname
where t01.databasename = <DATABASE_NAME>
order by t01.TableName, t03.ColumnId
;
