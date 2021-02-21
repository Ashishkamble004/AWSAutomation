today=$(date +"%Y-%m-%d")
instanceid=`cat serverlistinstance.txt | awk -F " " '{print $1}'`
ticket=`cat ticket.txt`
echo $ticket

for instance in $instanceid; do
echo $instance
InstanceName=$(aws ec2 describe-instances --instance-id $instance --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value]' --output text)
echo $InstanceName >> scriptdata.txt
echo $InstanceName
Deployment=$(aws ec2 describe-instances --instance-id $instance --query 'Reservations[*].Instances[*].[Tags[?Key==`Deployment`].Value]' --output text)
echo $Deployment
#Project=$(aws ec2 describe-instances --instance-id $instance --query 'Reservations[*].Instances[*].[Tags[?Key==`Project`].Value]' --output text)
#echo $Project
echo $InstanceName >> scriptdata.txt



AMID=$(aws ec2 create-image --instance-id $instance --name $ticket-$InstanceName-$today-GOLDEN --description $ticket-$InstanceName-$today-GOLDEN --no-reboot --output text)
echo $AMID >> scriptdata.txt
echo $AMID
aws ec2 create-tags --resources $AMID --tags Key=Name,Value=$InstanceName Key=Project,Value=LASTSYSTEMBACKUP Key=Deployment,Value=$Deployment Key=InstanceId,Value=$instance Key=Validity,Value=$NEXT_DATE
echo "Tags Added " >> scriptdata.txt

done
