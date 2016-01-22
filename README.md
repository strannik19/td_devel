documents
=========
Stuff what is necessarily not a source code. Eg. Word or Excel documents.

ELT
===
The idea is, to have an empty (new) TMS for ELT purposes.

With those packages, you will get
* git
* subversion
* SLJM (version 2.12)
* GCFR (ETL part) (version 1.2)

installed.

The Linux Environment (folder separation for Develop, Test, Production, ...) will be set up.
Unix groups and base environment for SLJM will be created (as well as /etc/skel prepared).

The packages are not supposed to be installed on TPA nodes.
They install new software and libraries (in /usr/local).

I'm not providing software packages here. You need to get them on your own.

GCFR
====
Helpful stuff for GCFR

INMOD
=====
INMODs for TTU.

oracle
======
Tools to run against Oracle Databases.

teradata
========
Tools to run against Teradata Databases.

tools
=====
Some other small helpful tools with no database involvement.

vbox_setup
==========
Prepared scripts to convert a VMware virtual machine to a VirtualBox virtual
machine. Currently test only with TDExpress_15.10.0.7 from 13.11.2015.
