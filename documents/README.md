Table_Definition.xslm
=====================
Excel document with macros to generate Teradata DDLs (create table, create view, ...)

Usual usage:

* The customer sends table definition in tabular (Excel) form from their existing Oracle database
* Bring this information into that document (sheets "coldata" and "tabdata") to define columns and tables
* Modify things (very common to be changed: datatypes, sizes, columnnames, giving (P)PI definition, MVC, ...)
* leverage the power of Excel with mass operations
* adjust Parameters in sheet "parameter"
* caution: the reserved words in sheet "reserved words" will be out of date. Get the latest from your database first.
Basically, all words will be treated as "reserved word" in sheet "coldata".
* generate a 1:1 staging layer in Teradata

The initial intention was, that the customer delivered table and column description for a migration project in Excel as

```
select * from all_tables where owner = 'BLABLA';
```

and

```
select * from all_tab_columns where owner = 'BLABLA';
```

If you have access to the desired Oracle database, you can use the script "/oracle/read_dd4Table_Definition.sql" to unload the data in that required format, just for copy and paste.

If you wonder, why the "NOT NULL" information is stored in the other way around databases does: "Required?"? It was designed, to have an easy unload from Erwin (Databrowser) as well.
Now, you can see, that this document was initially created while Erwin 7.3 was actual.
