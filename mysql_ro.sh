#!/bin/bash
while getopts d:u:a: flag
do
    case "${flag}" in
        d) database=${OPTARG};;
        u) dbuser=${OPTARG};;
        a) action=${OPTARG};;
    esac
done

c_dir=$(pwd)
log=$c_dir/dbs.log
date=$(date +'%a %d %b %H:%M:%S')
data_base=$(echo "$database" | sed 's/\_/\\\_/g' | sed 's/.*/\`&\`/')
RO="REVOKE UPDATE, INSERT, ALTER, CREATE, DELETE ON"
RW="GRANT UPDATE, INSERT, ALTER, CREATE, DELETE ON"
ro_success="$date Success: DB $data_base is RO now"
ro_fail="$date Failed: DB $data_base RO action failed with above error"
rw_success="$date Success: DB $data_base is RW now"
rw_fail="$date Failed: DB $data_base RW actionfailed with above error"

## Kill Sessions ##
mysql -e 'show processlist' | grep $dbuser | awk {'print "kill "$1";"'}| mysql

if [ $? -eq 0 ]; then
  echo "$date Success: Sessions for user $dbuser killed" >> $log
else
  echo "$date Failed: Sessions for user $dbuser not killed. Check manually" >> $log
fi

## Conditions ##
if [ -z "$action" ]; then
  echo "You have entered a empty action use ro or rw"
fi
###########
if [ $action = "ro" ]; then
   if [[ ! $database =~ ^[[:alnum:]]+$ ]];then
     mysql --execute "$RO $data_base.* FROM '$dbuser'@'%';" 2>> $log
        if [ $? -eq 0 ]; then
           echo "$ro_success" >> $log
        else
           echo "$ro_fail"  >> $log
        fi
  else
     mysql --execute "$RO $database.* FROM '$dbuser'@'%';" 2>> $log
        if [ $? -eq 0 ]; then
           echo "$ro_success" >> $log
        else
           echo "$ro_fail"  >> $log
        fi
fi
##########
elif [ $action = "rw" ];  then
  if [[ ! $database =~ ^[[:alnum:]]+$ ]];then
     mysql --execute "$RW $data_base.* TO '$dbuser'@'%';" 2>> $log
        if [ $? -eq 0 ]; then
           echo "$rw_success" >> $log
        else
           echo "$rw_fail"  >> $log
        fi
  else
    mysql --execute "$RW $database.* TO '$dbuser'@'%';" 2>> $log
        if [ $? -eq 0 ]; then
           echo "$rw_success" >> $log
        else
           echo "$rw_fail"  >> $log
        fi
fi
else
  echo "You have entered a invalid action";
fi