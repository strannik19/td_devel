#!/usr/bin/env bash

##########################################################################
#    vbox_setup.sh
#    Copyright (C) 2015  Andreas Wenzel (https://github.com/tdawen)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
##########################################################################

# This script is to Setup a new VirtualBox Machine and convert a
# TDExpress (provided in current folder) to VirtualBox
# Also do some configuration tasks.

#
# Unfortunately, some of the Virtual Machines provided by Teradata are
# in 7zip format, a Linux or Mac cannot unzip without installing a
# new unzipper. So, the unzip task must be done manually.
#

# for development set the parameters manually as variables
VirtualBox_Image_Folder="${HOME}/VirtualBox VMs"
VM_Name="TestMe"

# Even current folder can have vmdk files, give a name to use it for vm description
# For the VM description, only the part after the last slash is used.
OriVMdir="${HOME}/Downloads/TDExpress15.00.02_Sles11_40GB"

OStype="Linux26_64"
Memory="2048"
VRAM="64"
ACPI="on"
CPUs="2"
HostNetDev="en0"
NicType="82545EM"
Network="bridged" # Only bridged currently supported by script

#
# Check if VirtualBox is installed
#
VBoxM=$(which VBoxManage)

if [ -z ${VBoxM} ]
then
    echo "First requirement not satisfied: install Oracle VirtualBox"
    exit 1
fi


#
# Read arguments to give some parameters (coming later)
#


#
# Create function for errors
#
function ErrorVM() {
    echo "# Executing VM step ${Step} unsuccessful"
    if [ $(${VBoxM} list vms | grep -c "${VM_Name}") -eq 1 ]
    then
        #${VBoxM} unregistervm --delete "${VM_Name}"
        true
    fi
    exit 9
}


#
# Create function for execution and proper logging
#
function Exec() {
    Step=$1
    Command=$2
    echo "#"
    echo "# Executing VM step ${Step} with command: ${Command}"
    eval "${VBoxM}" ${Command} || ErrorVM
    echo "# Executed VM step ${Step} successfully"
    echo "#"
}


#
# Create function to get IP address from guest
#
function GetGuestIPaddress() {
    if [ -n ${VM_Name} ]
    then
        var1=$(${VBoxM} showvminfo "${VM_Name}" --machinereadable | grep macaddress1)

        # Assign macaddress1 the MAC address as a value
        eval $var1

        # Assign m the MAC address in lower case
        m=$(echo ${macaddress1} | tr '[A-Z]' '[a-z]')

        # This is the MAC address formatted with : and 0n translated into n
        mymac=$(echo `expr ${m:0:2}`:`expr ${m:2:2}`:`expr ${m:4:2}`:`expr ${m:6:2}`:`expr ${m:8:2}`:`expr ${m:10:2}`)

        # Get known IP and MAC addresses
        IFS=$'\n'; for line in $(arp -a); do
        #  echo $line
            IFS=' ' read -a array <<< $line
            ip=$(echo "${array[1]}" | tr -d "(" | tr -d ")")

            if [ "$mymac" = "${array[3]}" ]; then
              echo "$ip" | tr -d ' '
              break
            fi
        done
    fi
}


#
# Replace foldername if current folder holds *.vmdk files
#
if [ $(ls -1 ./*.vmdk 2>/dev/null | wc -l) -gt 0 ]
then
    echo "Found vmdk files in current folder. Use this one."
    OriVMname=${OriVMdir##*/}
    OriVMdir="."
else
    OriVMname=${OriVMdir##*/}
fi


#
# Check if TDExpress folder contains vmdk files
#
if [ $(ls -1 ${OriVMdir}/*.vmdk | wc -l) -lt 1 ]
then
    echo "No *.vmdk files found in folder ${OriVMdir}"
    exit 2
fi


#
# Check, if vm with this name already exists
#
if [ $(${VBoxM} list vms | grep -c "${VM_Name}") -eq 1 ]
then
    # For development only
    #Exec DropVM "unregistervm --delete \"${VM_Name}\""

    # After development enable those two command
    echo "Virtual Machine with this name already exists"
    exit 4
fi


#
# Start with setting up the Virtual Machine
#
Exec RegisterVM "createvm -name \"${VM_Name}\" --ostype ${OStype} --register --basefolder \"${VirtualBox_Image_Folder}\""

Exec SetDescription "modifyvm \"${VM_Name}\" --description \"TDexpress migrated from VMware image (${OriVMname##*/})\""

Exec SetMemory "modifyvm \"${VM_Name}\" --memory ${Memory} --vram ${VRAM} --acpi ${ACPI}"

Exec SetCPUs "modifyvm \"${VM_Name}\" --cpus ${CPUs}"

if [ "${Network}" == "bridged" ]
then
    Exec SetNetwork "modifyvm \"${VM_Name}\" --nic1 ${Network} --nictype1 ${NicType} --cableconnected1 on --bridgeadapter1 ${HostNetDev}"
fi

Exec AddSCSI "storagectl \"${VM_Name}\" --name \"SCSI\" --add scsi"

ScsiFile=()
for File in ${OriVMdir}/*.vmdk
do
    echo "#"
    echo "# Copying ${File} into VM folder"
    echo "#"
    cp -p ${File} "${VirtualBox_Image_Folder}/${VM_Name}"
    if [ $? -eq 0 ]
    then
        ScsiFile+=(${File})
    else
        ErrorVM
    fi
done

echo "Now, we need to check and probably change the file order"
newFiles=()
numFiles=${#ScsiFile[@]}
pos=0
startFiles=(${ScsiFile[@]})
while [ ${pos} -lt ${numFiles} ]
do
    (( fino = pos + 1 ))
    j=1
    unset myFiles
    for i in ${!ScsiFile[@]}
    do
        printf "  [%d] %s\n" $j ${ScsiFile[$i]}
        myFiles+=(${ScsiFile[$i]})
        (( j = j + 1 ))
    done

    echo "Please give number for file ${fino}/${numFiles}. Hit ENTER without number if order"
    echo -n "is correct (always confirm with enter): "
    read A
    if [ -z ${A} ]
    then
        for i in ${!ScsiFile[@]}
        do
            newFiles+=(${ScsiFile[$i]})
        done
        break
    elif [[ ${A} -gt 0 && ${A} -lt ${j} ]]
    then
        (( B = A - 1 ))
        newFiles+=(${myFiles[$B]})
        unset myFiles[$B]
        #ScsiFile[$i]=( "${ScsiFile[@]/$B}" )
        (( pos = pos + 1 ))
        echo ""
    else
        echo -e "Input \"${A}\" not allowed! Please repeat!\n"
    fi
    unset ScsiFile
    ScsiFile=(${myFiles[@]})
done

for i in ${!newFiles[@]}
do
    Exec AddSCSI "storageattach \"${VM_Name}\" --storagectl \"SCSI\" --port ${i} --type hdd --medium \"${VirtualBox_Image_Folder}/${VM_Name}/${newFiles[$i]##*/}\""
done

#Exec StartVM "startvm --type headless \"${VM_Name}\""
Exec StartVM "startvm \"${VM_Name}\""

echo "# VM is starting. Give it 2 minutes ..."
sleep 120

timeout=5
while [ ${timeout} -gt 0 ]
do
    GuestIP=$(GetGuestIPaddress)

    if [ -z ${GuestIP} ]
    then
        (( timeout = timeout - 1 ))
        if [ ${timeout} -gt 1 ]
        then
            echo "# Cannot determine guest IP address. Wait 30 seconds, and try again. ${timeout} tries left"
        else
            echo "# Cannot determine guest IP address. Wait 30 seconds, and try again. Last try"
        fi
        sleep 30
    else
        break
    fi
done

if [ ${timeout} -eq 0 ]
then
    echo "# Unable to determine guest IP address. Giving up here!"
    exit 10
else
    echo "# IP address for guest found: ${GuestIP}"
fi

EXPECT=$(whereis expect)
if [ -z ${EXPECT} ]
then
    echo -e "\n# Tool expect not available on host. Skipping following automatic tasks to setup guest:"
    echo "#  - Uploading public key as authorized_key in user root"
    echo "#  - Changing nameserver to match the default gateway of host"
    echo "#  - Downloading td-devel package from github and installing it"
    echo -e "\n# Preparation of guest VM done as much as possible"
    exit 0
fi

#
# Now, we are going to setup ssh login
#
if [ ! -e ${HOME}/.ssh ]
then
    # really first time ... ??? ;)
    mkdir ${HOME}/.ssh
    chmod 700 ${HOME}/.ssh
fi

if [ -d ${HOME}/.ssh ]
then
    if [ ! -e ${HOME}/.ssh/known_hosts ]
    then
        touch ${HOME}/.ssh/known_hosts
        chmod 600 ${HOME}/.ssh/known_hosts
    else
        # keep a max of five backups
        num_backups=$(ls -1 ${HOME}/.ssh/known_hosts.vmbox-setup-backup.* 2>/dev/null | wc -l)
        if [ ${num_backups} -ge 5 ]
        then
            (( num_delete = num_backups - 4 ))
            rm $(ls -1t ${HOME}/.ssh/known_hosts.vmbox-setup-backup.* | tail -${num_delete})
        fi

        mv ${HOME}/.ssh/known_hosts ${HOME}/.ssh/known_hosts.vmbox-setup-backup.$$
        grep -v "${GuestIP}[ \,]" ${HOME}/.ssh/known_hosts.vmbox-setup-backup.$$ >${HOME}/.ssh/known_hosts
        ssh-keyscan ${GuestIP} 2>/dev/null >>${HOME}/.ssh/known_hosts
    fi
fi

if [[ -s ${HOME}/.ssh/id_rsa && -s ${HOME}/.ssh/id_rsa.pub ]]
then
    echo -e "\n# Found private/public key files"
    echo "# Using public key to load to user root of guest"
    echo "# This step probably takes some time, because the Virtual Machine is delivered"
    echo "# with a nameserver configured, we probably don't have in our network. And SSH"
    echo "# Is running a reverse lookup of our client causing this step to take very long"
    echo "# So, be patient and don't interrupt"
    PubKey=$(<${HOME}/.ssh/id_rsa.pub)
    {
        echo "set timeout -1"
        # now connect to guest and prepare private/public key login
        echo "spawn ssh root@${GuestIP} \"mkdir \\\${HOME}/.ssh; chmod 700 \\\${HOME}/.ssh; echo \\\"${PubKey}\\\" >\\\${HOME}/.ssh/authorized_keys\""
        echo 'match_max 100000'
        # Look for passwod prompt
        echo 'expect "*?assword:*"'
        # Send password aka $password
        echo 'send -- "root\r"'
        # send blank line (\r) to make sure we get back to gui
        echo 'send -- "\r"'
        echo 'expect eof'
    } | expect >/dev/null 2>&1
else
    echo -e "\n# No private/public key found. Start creating."
    echo "# Please just hit enter when asked for"
    echo "#  - where to save the keys"
    echo "#  - Enter passphrase"
    echo "#  - repeat passphrase"
    ssh-keygen
fi

echo -e "\n# Now we change /etc/resolv.conf because there are name servers in there."
echo "# And it's very likely, we don't have them in our network."
echo "# Setting them to our default gateway"
defaultGW=$(route -n get default | awk '/gateway/ {print $2}')
if [ -n ${defaultGW} ]
then
    ssh root@${GuestIP} "echo \"nameserver ${defaultGW}\" >/etc/resolv.conf" >/dev/null 2>&1
else
    echo "# Cannot determine ip address of default gateway"
fi


echo -e "\n# Now we set the hostname of guest to VM name."
ssh root@${GuestIP} "hostname ${VM_Name}"
ssh root@${GuestIP} "echo '${VM_Name}' >/etc/HOSTNAME"

ssh root@${GuestIP} "mv /etc/hosts /etc/hosts.vbox_setup"
ssh root@${GuestIP} "awk --assign=vm=${VM_Name} --assign=vmcop1=${VM_Name}cop1 '/^127.0.0.1/ {print \$0, vm, vmcop1; next} {print}' </etc/hosts.vbox_setup >/etc/hosts"


if [ -s to_be_executed_in_guest.sh ]
then
    echo -e "\n# So, now upload script to_be_executed_in_guest.sh to guest and execute it!"
    echo "# We will download TD developers package from Github and use those scripts"
    echo "# to automatically install some addition helpful tools:"
    echo "#  - Subversion"
    echo "#  - Git"
    scp to_be_executed_in_guest.sh root@${GuestIP}:.
    if [ $? -eq 0 ]
    then
        echo "# Executing script inside guest. Please be patient ..."
        ssh root@${GuestIP} "./to_be_executed_in_guest.sh"
    else
        echo "# Error copying script to_be_executed_in_guest.sh to guest via SSH"
    fi
else
    echo -e "\n# Script to_be_executed_in_guest.sh not found. So we cannot install some"
    echo "# additional helpful tools:"
    echo "#  - Subversion"
    echo "#  - Git"
fi
