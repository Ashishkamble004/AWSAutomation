#Author: Ashish Kamble.
#Date: 17th Dec 2020

#Script get details such as Endpoints, Default Database(Primary DB), And Project for a given RDS.

#echo "Enter Email ID for sending details: "
#read id

#echo " "

#echo "Confirmed Email ID: $id "
#echo " "

echo "Getting Details for the list of RDS in listofrds.txt file. Please add the list if not done."
echo " "

dbname=`cat listofrds.txt`

for i in $dbname; do

resource=$(aws rds describe-db-instances --db-instance-identifier $i --query 'DBInstances[*].[DBInstanceArn]' --output text)
endpoint=$(aws rds describe-db-instances --db-instance-identifier $i --query 'DBInstances[*].[Endpoint.Address]' --output text)
name=$(aws rds describe-db-instances --db-instance-identifier $i --query 'DBInstances[*].[DBName]' --output text)


project=$(aws rds list-tags-for-resource --resource-name $resource --query 'TagList[]|[?contains(Key, `Project`) == `true`]' --output text)
echo "---------------------------------------------------------------" >> Result.txt
echo " " >> Result.txt
echo "Instance Details : " >> Result.txt
echo "Endpoint: $endpoint " >> Result.txt
echo "Database Name: $name " >> Result.txt
echo "Project Details are : $project " >> Result.txt
done

echo " "
#echo "Mailing the details to $id " | mailx -r <mail-id> -s "Details for your requested RDS" $id -a Result.txt
cp Result.txt Result_`date +"%Y-%m-%d"`.txt

echo "Your Output File is Result_Date"
rm -f Result.txt
echo "Thank You!"
