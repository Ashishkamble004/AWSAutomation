echo "Checking if /var exeeding threshold"
space=`df -h /var/|awk '{print $5}'|sed -n 2p|sed 's/%//'`
if [ "$space" -ge "80" ]
then
cd /var/log
ls *[0-9]*|grep '.gz' | while read line; do gzip $line;done
fi

echo "Checking space again on /var"
space1=`df -h /var/|awk '{print $5}'|sed -n 2p|sed 's/%//'`

if [ "$space1" -ge "65" ]
then
cd /var/log
echo "Deleting file older than 30 days"
find -mtime +30 | grep '.gz'| while read line;do rm -rf $line;done
fi
