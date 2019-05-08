#!/bin/bash

#############################################################################################################################################
## SCRIPT: ORTHDHD.sh
## AUTHOR: Manoj Kumar
## CREATED: Oct 12, 2016
## LAST UPDATED: XXXXXXXX
## PURPOSE:This script is providing the Ordering Thread dumps,Heapdumps,Sar Report and Top Report
## Run as ./ORTHDHD.sh
#############################################################################################################################################

#Script providing server details to user

echo -e "\e[1;32m List of Ordering Servers \n lxomavmecom120" \(\A\,1\) "\n" "lxomavmecom121" \(\2\) "\n" "lxomavmecom122" \(\3\,4\) "\n" "lxomavmecom123" \(\5\,6\) "\n" "Please enter the server name for which you need work like Example: lxomavmecom120\e[0m"
echo -e "\e[1;31mEnter the Server Names: \e[0m\c"
read x

#Timer starts which providing the time taken by the script to execute
Timer()
{
        date2=$(date +"%s")
        diff=$(($date2-$date1)) >/dev/null 2>&1
        echo -e "\n\033[1;36m$(($diff / 60))\033[0m minutes and \033[1;36m$(($diff % 60))\033[0m seconds elapsed."
}

#{
#START_TIME=$SECONDS
#ELAPSED_TIME=$(($SECONDS - $START_TIME))
#echo "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"
#}


# Business logic starts here

appid="ordering"
for server in $x
do
        echo -e "This is WLS server\n"
        log_dir=`ssh -q $server ls -d /data/ecom2/bea/*/log/archive | grep $appid` > /dev/null 2>&1
        x=`ssh -q $server ps -aef |grep $appid |grep jdk_*_*` > /dev/null 2>&1
        java_hom=`echo $x | awk '{print $8}' |grep -v grep | sed 's/java//g' |tail -1` 1> /dev/null
       #echo "Java_Home=$java_hom"
       date1=$(date +"%s")
        for y in `ssh -q $server ps -aef |grep $appid | grep "/prod/appl/" | grep -v grep| awk '{print $2}'`
        do
       #echo -e "Javaid = $y\n"
        instance=`ssh -q $server ps -aef |grep $y |grep -v grep| awk '{print $10}'|tr -d "-"`
        ssh -q $server "$java_hom"jstack $y  >> /tmp/MJK/Threaddump$instance.log_`date +%Y%m%d`
        ssh -q $server "$java_hom"jmap -J-d64 -heap $y >> /tmp/MJK/Heapdump_$instance.log_`date +%Y%m%d`
        ssh -q $server sar -A >> /tmp/MJK/SARData$instance.log_`date +%Y%m%d`
        ssh -q $server top -b -n 10 -c -u $appid >> /tmp/MJK/TOPData$instance.log_`date +%Y%m%d`
        chmod 777 /tmp/MJK/Threaddump$instance.log_`date +%Y%m%d`
        chmod 777 /tmp/MJK/Heapdump_$instance.log_`date +%Y%m%d`
        chmod 777 /tmp/MJK/SARData$instance.log_`date +%Y%m%d`
        chmod 777 /tmp/MJK/TOPData$instance.log_`date +%Y%m%d`

        scp  /tmp/MJK/Heapdump_$instance.log_`date +%Y%m%d` /tmp/MJK/Threaddump$instance.log_`date +%Y%m%d` /tmp/MJK/SARData$instance.log_`date +%Y%m%d` /tmp/MJK/TOPData$instance.log_`date +%Y%m%d` $server:$log_dir   >/dev/null 2>&1




echo -e "\e[1;32m \n\n******************************************************\n Threaddump$instance.log \n Heapdump_$instance.log_`date +%Y%m%d` \n SARData$instance.log_`date +%Y%m%d` \n TOPData$instance.log_`date +%Y%m%d` \n File has been copied into \n $log_dir Directory \n ******************************************************* \n\n  \e[0m"


rm  /tmp/MJK/*.*

        done
done

Timer