today=$(date +"%Y-%m-%d")
instanceid=`cat serverlistinstance.txt | awk -F " " '{print $1}'`

for instance in $instanceid; do
echo $instance
InstanceName=$(aws ec2 describe-instances --instance-id $instance --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value]' --output text)
echo $InstanceName >> scriptdata.txt
echo $InstanceName
Deployment=$(aws ec2 describe-instances --instance-id $instance --query 'Reservations[*].Instances[*].[Tags[?Key==`Deployment`].Value]' --output text)
echo $Deployment
echo $InstanceName >> scriptdata.txt


AMID=$(aws ec2 create-image --instance-id $instance --name $InstanceName-$today --description $InstanceName-$today --no-reboot --output text)
echo $AMID >> scriptdata.txt
echo $AMID

done
