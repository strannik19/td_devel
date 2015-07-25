-- #########################################################################
--     show_skew_factor.sql
--     Copyright (C) 2015  Andreas Wenzel (https://github.com/awenny)
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


-- Show Skew factor of tables in database
-- Change databasename

SELECT DatabaseName, TableName,SUM(CurrentPerm) AS CurrentPerm,SUM(PeakPerm) AS PeakPerm,
    (100 - (AVG(CurrentPerm)/MAX(CurrentPerm)*100)) AS SkewFactor
FROM Dbc.TableSize
WHERE DataBaseName = <DATABASE_NAME>
GROUP BY 1
ORDER BY 2
;
