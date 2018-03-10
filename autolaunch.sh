#!/bin/bash

for(( ; ; )) ; do
    gcloud compute instances list | grep RUNNING
    running=$?
    gcloud compute instances list | grep TERMINATED
    terminated=$?
    echo $running $terminated
    [ 0 -eq $running ] && gcloud compute instances list | grep RUNNING | awk '{print $6;}' > remote_host
    if [ 0 -eq $terminated ] ; then
        gcloud compute instances start instance-1
        sleep 5
        remote_host=$(cat remote_host)
        echo "xxxxxxxx" > remote_host
        kill $(ps aux | egrep '(ssh|scp)' | grep $remote_host | awk '{print $2;}')
        sleep 5
        kill $(ps aux | egrep '(ssh|scp)' | grep $remote_host | awk '{print $2;}')
        sleep 5
        kill $(ps aux | egrep '(ssh|scp)' | grep $remote_host | awk '{print $2;}')
        sleep 5
        kill $(ps aux | egrep '(ssh|scp)' | grep $remote_host | awk '{print $2;}')
        sleep 5
        kill $(ps aux | egrep '(ssh|scp)' | grep $remote_host | awk '{print $2;}')
        sleep 5
        kill $(ps aux | egrep '(ssh|scp)' | grep $remote_host | awk '{print $2;}')
    fi

    sleep 60
done
