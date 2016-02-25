Idea
====
The idea is, to have an empty (new) TMS for ETL purposes.
With those packages, you will get

* git (version 2.7.2)
* subversion (version 1.9.3)
* SLJM (version 2.12)
* GCFR (ETL part) (version 1.2)

installed.

The Linux Environment (folder separation for Develop, Test, Production, ...)
will be set up. Run "setup.sh" for every Environment (free naming)
Unix groups and base environment for SLJM will be created (as well as /etc/skel)

The packages are not supposed to be installed on TPA nodes.
They install new software and libraries (under /usr/local), but one cannot
guarantee, that nothing happens!

Install_GCFR_Requirements_SLES11SP1
===================================
You need to have an Account at Novell, to be able to download those official RPMs for SLES11SP1:

* perl-XML-NamespaceSupport-1.09-1.22.x86_64.rpm
* perl-XML-Parser-2.36-1.18.x86_64.rpm
* perl-XML-SAX-0.96-2.7.x86_64.rpm
* perl-XML-Simple-2.18-1.15.x86_64.rpm

The script "download.sh" will download the free software for you. You will just need to get the
official RPMs from Novell (or some other trusted source).

Install_SLJM_Requirements_SLES11SP1
===================================
You need to have an Account at Novell, to be able to download those official RPMs for SLES11SP1:

* tack-5.6-90.55.x86_64.rpm
* libncurses6-5.6-90.55.x86_64.rpm
* ncurses-devel-5.6-90.55.x86_64.rpm

Install_GCFR_SLJM_Environment_SLES11SP1
===================================
If you are an Teradata Employee, then you know how to get those packages:

* SLJM (AssetID: KA67919)
* GCFR (AssetIDs: Software: KA66947, Documentation: KA66948)

If you don't know, what SLJM or GCFR is, then you don't need that package anyway.

Install_TD_Developers_Package_SLES11SP1
=======================================
The main goal for this package is the installation of this packages:

* git
* subversion

But both tools require some additional software installed from source before.

* apr
* apr-util
* curl
* openssl
* scons-local
* serf
* sqlite-amalgamation

Training_Lab
============
The installation scripts provided for the GCFR Training Lab.
