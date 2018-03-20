#!/bin/bash

instance=instance-1
zone=us-central1-c

for(( ; ; )) ; do
    gcloud compute instances list | grep ${instance} | grep RUNNING
    running=$?
    gcloud compute instances list | grep ${instance} | grep TERMINATED
    terminated=$?
    echo $running $terminated
    [ 0 -eq $running ] && gcloud compute instances describe --zone ${zone} ${instance} | grep natIP | awk '{print $2;}' > remote_host
    if [ 0 -eq $terminated ] ; then
        gcloud compute instances start --zone=${zone} ${instance}
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
