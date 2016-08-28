! /bin/bash

display_usage(){
	echo -e "\nExample Usage:\n$0 us-west-2 \n" 
	}

if [ $# -lt 1 ]  
then
	display_usage
	exit 1
fi

REGION=$1 
echo "Compiling a list of all instances in $REGION"
aws ec2 describe-instance-status --region $REGION | grep -i "InstanceId" | cut -d ":" -f 2

echo Which instance do you want to termninate?
read INSTANCE_ID


while read line
do
    vol[ $i ]="$line"
    echo "Volume to be deleted - ${vol[$i]}"
    i=$[$i+1]
done < <(aws ec2 describe-instances --region $REGION --instance $INSTANCE_ID | awk '/VolumeId/{gsub(/[",]+/, "", $2); print $2}')



echo "Deleting instnace $INSTANCE_ID"
aws ec2 terminate-instances --region $REGION --instance-ids $INSTANCE_ID

date
echo "Waiting for 2 min before initiating volume deletions because \
it takes some time for them to get disassociated"

sleep 120

echo "Volumes to be deleted - ${vol[@]}"
for index in "${!vol[@]}"
do
        length=$index
done
#echo $length

i=0
while [ $i -le $length ]
do 
	aws ec2 delete-volume --region $REGION --volume-id ${vol[$i]} || true 
	echo Deleting ${vol[$i]}
	 i=$[$i+1]
done 
