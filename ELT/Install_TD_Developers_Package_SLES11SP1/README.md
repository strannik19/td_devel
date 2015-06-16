certGithub.pem
==============
A selection of root certificates.

download.sh
===========
Downloads the mentioned versions from all free packages. Download of official SLES RPMs must still be done individually.

install.sh
==========
The main part. Download all packages with required versions into same folder as this script.

*Attention:* at some point, it looks like the installation hangs. The problem is, that the ODBC installation routine is
asking for an ENTER. So simply hit ENTER, and it will be finished successfully shortly.

md5sum.txt
==========
Is for checking if all packages are available, and files are OK.
The installation will not proceed, if an error occurs while check of md5 sums.
