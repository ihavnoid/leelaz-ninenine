#!/bin/bash

suffix=$1
gpunum=$2

for((i=0;i<50000;i=i+1)) ; do
    resign_rate=$(((i%2)*10))
    timestamp=$(date +%y%m%d_%H%M%S)_${suffix}
    latest_weight=$(ls -1c training/tf/*.txt | head -1)
    leelaz_cmd="src/leelaz-current -q -m 8 -n -d -r $resign_rate -t 1 -p 400 --noponder --gtp --gpu $gpunum"
    sleep 5
    echo leelaz_cmd : $leelaz_cmd
    echo latest_weight : $latest_weight
    echo timestamp : $timestamp
    echo autotrain traindata_${timestamp} 25 \n quit | ${leelaz_cmd} -w $latest_weight 
done
