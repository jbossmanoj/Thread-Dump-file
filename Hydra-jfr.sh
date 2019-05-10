#!/bin/bash
#############################################################################################################################################
## SCRIPT: ENT_JFRTHST.sh
## AUTHOR: Manoj Kumar
## CREATED:Sept 13, 2018
## LAST UPDATED: Dec 18, 2018 By Manoj Kumar
## PURPOSE:This script is providing the HYDRA Java Flight Recording, Thread dumps,Heapdumps,Sar Report and Top Report
## Run as ./HYDRA_JFRTHST.sh
#############################################################################################################################################

#Script providing server details to user
clear
echo -e "\e[1;42m This script will provide JAVA Flight Recording,Threaddumps,SAR,TOP Report per corrospondig server \e[0m"
echo -e "\e[1;32m List of Entervices Servers \n server776" "\n" "server777" "\n" "server778" "\n"  "Please enter the server name for which
you need work like Example: server776\e[0m"
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
#appid="eslapp"
appid="hydra"
appname="hyddrocyl"
for svr in $x
do

        log_dir=`ssh -q $svr ls -ld /foss/foss-ews/instances/hydra/current/logs/archive | grep $appid|awk '{print $9}'`
        echo -e "\033[32mLog Dir = $log_dir\033[0m"
        Bootstrap_pid=`ssh -q $svr jps | grep Bootstrap|awk '{print $1}'`
        Foss_pid=`ssh -q $svr jps | grep Bootstrap|awk '{print $1}'`
        echo -e "\033[36mFossid: $Foss_pid\033[0m\n"
        #echo -e "\033[34mEWSId: $Bootstrap_pid\033[0m\n"
        date1=$(date +"%s")
        ssh -q $svr "jmap -dump:format=b,file=$log_dir/HeapDump_$appname.log $Bootstrap_pid"
        ssh -q $svr "chmod 777 $log_dir/HeapDump_$appname.log"
        echo -e "\n\n\033[7mFoss EWS svr Java Flight Record Initiated\033[0m \n\n"
        ssh -q $svr "jcmd $Bootstrap_pid JFR.start delay=10s duration=130s filename=$log_dir/JFR_$appname.log"
        ssh -q $svr "chmod 777 $log_dir/JFR_$appname.log"
        ssh -q $svr "jstack $Foss_pid >> $log_dir/Threaddump_$appname.log"
        sleep 10
        ssh -q $svr "jstack $Foss_pid >> $log_dir/Threaddump_$appname.log"
        sleep 10
        ssh -q $svr "jstack $Foss_pid >> $log_dir/Threaddump_$appname.log"
        sleep 10
        ssh -q $svr "jstack $Foss_pid >> $log_dir/Threaddump_$appname.log"
        ssh -q $svr "sar -A >> $log_dir/SAR_$appname.log"
       # ssh -q $svr "chmod 777 $log_dir/SAR_$appname.log"
        ssh -q $svr "top -b -n 10 -c -u `whoami` >> $log_dir/TOP_$appname.log"
        ssh -q $svr "chmod 777 $log_dir/TOP_$appname.log"

        ssh -q $svr "chmod 777 $log_dir/Threaddump_$appname.log | chmod 777 $log_dir/SAR_$appname.log | chmod 777 $log_dir/TOP_$appname.log | chmod 777 $log_dir/JFR_$appname.log | chmod 777 $log_dir/HeapDump_$appname.log"
#sleep 06
#ssh -q $svr "gzip $log_dir/Threaddump_$appname.log | gzip $log_dir/TOP_$appname.log | gzip $log_dir/SAR_$appname.log | gzip $log_dir/JFR_$appname.log | gzip  $log_dir/HeapDump_$appname.log"
done
Timer
