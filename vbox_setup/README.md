Introduction
============
Those two scripts are to convert a VMware virtual machine into a VirtualBox
machine.
Also, some additional configuration steps will be executed in guest.

# Requirements
- VirtualBox from Oracle installed (always best to use the latest release)
- TDExpress virtual machine uncompressed in same folder as the scripts
- Bash environment to be able to execute the vbox_setup.sh script

# State of development
This is an early state of development, I have tested it only with
- Apple Mac OS X El Capitan (10.11.2 and 10.11.3)
- Oracle VirtualBox 5.0.12 and 5.0.14
- TDExpress 15.10.0.7 from 13.11.2015
- TDExpress 15.00.02 from 30.06.2015 (seeing currently some issues)

So, please be cautious.

# Contribution
If you find it useful, and see some room for improvement or issues, please
contact me or send a PR via GitHub.

# Components
These are the two components I have prepared. The first one is mandatory, the
second is optional.

## vbox_setup.sh
This is the main script to create a new VirtualBox machine from an VMware
virtual machine. For managing the new virtual machine, the tool "VBoxManage"
(comes usually together with VirtualBox) is used.

It will do following tasks:

1. Create a new virtual machine
2. Copy the vmdk files into the new virtual machine folder
3. Add those copied vmdk files to virtual machine
4. Set the network interface to "bridged"
5. If a file id_rsa.pub is found in ${HOME}/.ssh, install it in user root of
   guest as ${HOME}/.ssh/authorized_keys (tool expect is used to logon)
6. Change guest hostname to VM name
7. Change nameserver in guest to default gateway of the host
8. If the script to_be_executed_in_guest.sh is found in current folder, send it
   to guest and execute it there.

## to_be_executed_in_guest.sh
This is an automated way to install some additional (modern) tools helpful to
developers.

It will do following tasks:

1. Download td_devel repository from my (tdawen) GitHub to get access to
   installation scripts for "Install_TD_Developers_Package_SLES11SP1"
2. Unpack the downloaded zip file and change into above folder
3. Run script download.sh to download all required public software packages
   from the internet
4. Run script install.sh to install all required components for tools
   - git
   - Subversion

After that, the tools "git" and "svn" can be used.

# What to do now?
1. Unzip the zip file (sometimes a 7z) of the original virtual machine into the
   folder with those scripts (after you have cloned this repository into your
   local filesystem)
2. Modify the vbox_setup.sh script by changing the variables to your needs
3. Goto the vbox_folder (or wherever your unzipped original VM and those
    scripts are located)
4. Start with `./vbox_setup.sh`
5. Wait and watch :smiley:

If you see issues, please get in contact with me, or create an issue.
