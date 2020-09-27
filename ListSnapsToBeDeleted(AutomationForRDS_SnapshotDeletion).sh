#RDS Snapshot AutoDeletion -- Version 1.0
#Created By -- Ashish.K.Kamble
#Date -- 21/9/2020

#Setting Environment Variables
today=$(date +"%Y-%m-%d")
SnapsTarget=$(date +%Y-%m-%d -d "$today - 14 day")

#AWS Command to Extract the list of RDS Snaps
aws rds describe-db-snapshots --snapshot-type manual --query 'DBSnapshots[*]|[?SnapshotCreateTime<=`'${SnapsTarget}'` && !contains(DBSnapshotIdentifier, `final`) == `true` && !contains(DBSnapshotIdentifier, `adhoc`) == `true` && !contains(DBSnapshotIdentifier, `golden`) == `true`].[DBSnapshotIdentifier,SnapshotCreateTime,AllocatedStorage]' --output table > SnapshotDetailsList.csv

#COPY Output File to Backup File with DATE
cp SnapshotDetailsList.csv SnapshotListBackup_`date +"%Y-%m-%d"`.csv

#ListingOut Snapshot To Be Deleted in DeletingSnaps.txt File
awk '{print $2}' SnapshotDetailsList.csv > DeletingSnaps.txt


#For-Loop For Deleting Snaps Listed in the DeletingSnaps.txt File
snaplist=`cat DeletingSnaps.txt`

for i in $snaplist; do
echo "Starting to Delete $i" >> DeletedSnapshots_`date +"%Y-%m-%d"`.txt

#Command To Delete the Snapshot Listed
#aws rds delete-db-snapshot --db-snapshot-identifier $i

echo "Deleted $i Successfully" >> DeletedSnapshots_`date +"%Y-%m-%d"`.txt
done

#OUTPUT Send to OutputFile after all the successfull deletion
echo "Snapshot Listed for $SnapsTarget has been Deleted SuccessFully" >> DeletedSnapshots_`date +"%Y-%m-%d"`.txt

#CostCalculation For the Deleting Snapshots
awk '{print $6}' SnapshotDetailsList.csv > snapshotsize.txt
costvar=`cat snapshotsize.txt`

for i in $costvar; do
a=`bc<<<"$i*0.095"`
echo $a >> calculatetemp.txt
done
TotalCost=`awk 'BEGIN{sum=0} {sum=sum+$1} END {print sum}' calculatetemp.txt`
echo "Total Cost Saved For the Run on $today is $TotalCost " > TotalCostSaved_`date +"%Y-%m-%d"`.txt

#Deleting Data from Temporary Generated Files
echo " " > snapshotsize.txt
echo " " > calculatetemp.txt

#MAILING Generated Attachments to Recipients
echo "Attaching Generated Documents for the Run on $today . Total Savings Done are $TotalCost $ " | mutt -s "DAILY-RDS-SNAPSHOT-DELETION-JOB-RUN" kambleashish004@gmail.com -a SnapshotListBackup_`date +"%Y-%m-%d"`.csv DeletedSnapshots_`date +"%Y-%m-%d"`.txt
