-- #########################################################################
--     gen_col_pi_stats.sql
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

-- Collect statistics on PI
-- Change Databasename

select
    (case
        when t01.columnposition = min_col_pos then 'collect statistics on '||trim(both from t01.databasename)||'.'||trim(both from t01.tablename)||' index ('
        else '  ,'
    end)||
    trim(both from t01.columnname)||
    (case
        when t01.columnposition = max_col_pos then ');'
        else ''
    end)
from  dbc.indices t01
join  (select databasename, tablename, min(columnposition) min_col_pos, max(columnposition) max_col_pos from dbc.indices where indextype = 'P' group by 1, 2) t02
on    t01.databasename = t02.databasename
and   t01.tablename = t02.tablename
where t01.databasename = <DATABASE_NAME>
and   t01.indextype = 'P'
order by t01.databasename, t01.tablename, t01.columnposition
;
