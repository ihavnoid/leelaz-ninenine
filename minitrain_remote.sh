#!/bin/bash

SSH="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -q"
SCP="scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -q"
suffix=$1
gpunum=$2

for((i=0;i<50000;i=i+1)) ; do
    host=$(cat remote_host)
    resign_rate=$((i%5+5))
    timestamp=$(date +%y%m%d_%H%M%S)_${suffix}
    latest_weight=$(ls -1c training/tf/*.txt | head -1)
    leelaz_cmd="leela-zero/src/leelaz-current -q -m 8 -n -d -r $resign_rate -t 1 -p 400 --noponder --gtp --gpu $gpunum"

    echo host : $host
    echo leelaz_cmd : $leelaz_cmd
    echo latest_weight : $latest_weight
    echo timestamp : $timestamp
    echo 'echo autotrain traindata_${1} 25 \n quit | ' ${leelaz_cmd} '-w ${1}.txt' > ${timestamp}_run.sh
    chmod 700 ${timestamp}_run.sh

    sleep 5 

    ${SSH} ${host} sudo nvidia-smi -pm 1
    ${SCP} -C ./$latest_weight ${host}:${timestamp}.txt
    ${SCP} -C ./${timestamp}_run.sh ${host}:${timestamp}_run.sh
    ${SSH} ${host} ./${timestamp}_run.sh ${timestamp}
    ${SCP} -C "${host}:traindata_${timestamp}*" .
    ${SSH} ${host} rm -f "*${timestamp}*"
    rm -f ${timestamp}_run.sh
done
