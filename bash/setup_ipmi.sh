#!/bin/bash

regex="([0-9]{1,3}[\.]){3}[0-9]{1,3}"

if [[ "$1" =~ "--reset" ]]
then
	ipmitool user set name 2 ADMIN
	ipmitool user set password 2 •••••••••
	echo "NEW Login:Password — ADMIN:•••••••••"
	shift
fi
if [ -z "$1" ]; then
	read -p "Input FQDN or IP-address: " input
else
		input=$1
fi

if [[ "$input" =~ $regex ]]
then
	ip=$input
else
	hostname=$input
	ip=$(host $hostname 2>&1 | head -n 1 | awk '{print $NF}')
	if [[ "$ip" =~ $regex ]]
	then
		echo -e "\nAddress of $hostname found!\n"
	else
		# echo "Error! Run script with IP"; exit 1
		ip=$(host $hostname".ipmi" 2>&1 | head -n 1 | awk '{print $NF}')
		if [[ "$ip" =~ $regex ]]
		then
			echo -e "\nAddress of $hostname".ipmi" found!\n"
		fi
	fi
fi
if [ -z "$2" ]
then
	netm="255.255.255.0"
else 
	netm=$2
fi
if [ -z "$3" ]
then
	defg=`echo $ip | awk -F "." '{printf($1"."$2"."$3".1")}' `
else 
	defg=$3
fi
echo "IPMI IP:		"$ip
echo "NETMASK:		"$netm
echo "DEFAULT GATEWAY:	"$defg
ipmitool lan set 1 ipsrc static
ipmitool lan set 1 ipaddr $ip
ipmitool lan set 1 netmask $netm
ipmitool lan set 1 defgw ipaddr $defg
reboot
