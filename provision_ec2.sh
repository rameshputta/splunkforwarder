#!/bin/bash
Usage()
{
	echo -e "USAGE:\nExample: $0 <Server-Name> <AWS Region>"
	echo -e "\nExample: $0 udp-collector20 us-east-1"
}

if [ "$#" -ne 2 ]
	then
		Usage
		exit 1
	fi

NAME=$1
REGION=$2

date

cd /etc/ansible
ansible-playbooks playbooks/provision_aws_pb.yml -e "NAME=$NAME"

ID=$(ec2-describe-tags --region $REGION | grep $NAME | awk '/instance/{ print $3}')
IP=$(aws ec2 describe-instances --region $REGION --instance-ids $ID | awk ' /"PrivateIpAddress"/{gsub(/[",]+/, "", $2);print $2}' | sed -n '1p')

echo "IP": $IP
echo "ID": $ID

cd /etc/ansible
ansible-playbook playbooks/updt_hosts_file_pb.yml -e "ENV=qa IP=$IP SRVR_NAME=$NAME"

cd /etc/ansible
ansible-playbook playbooks/updt_inventory_file_pb.yml -e "MCN=$NAME"

echo "Sleep 2 minutes before it can provision base role"
date
cd /etc/ansible
ansible-playbook /playbooks/base_pb.yml -e "target=$NAME"
