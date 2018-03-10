#!/bin/bash

for((i=0; i<1000; i=i+1)) ; do
    latest=$(ls -1c *.txt | head -1 | sed 's/\.txt//g')
    num_nets=$(ls -1 ../../traindata_* | wc -l)

    setsid nice python3 parse.py ../../traindata_ ${latest}
    
    latest=$(ls -1c *.txt | head -1 | sed 's/\.txt//g')
    echo $latest | egrep "00000$"
    has_four_zero=$?

    if ((has_four_zero == 0)) ; then
        prev_latest=$(ls -1c *00000.txt | head -2 | tail -1 | sed 's/\.txt//g')
        # setup ringmaster
        echo $latest
        cat ringmaster.template.ctl | sed 's/P1/'${latest}'/g;s/P2/'${prev_latest}'/g' > ringmaster.${latest}.ctl
        ../../../playoff/gomill-0.8/ringmaster ./ringmaster.${latest}.ctl run 
    else
        sleep 10
    fi
    
    # every minute we check if we accumulated 30 more nets
    prev_num_nets=$num_nets
    for ((num_nets=$(ls -1 ../../traindata_* | wc -l) ; $((num_nets/30)) == $((prev_num_nets/30)) ; num_nets=$(ls -1 ../../traindata_* | wc -l) )) ; do
        echo "prev : " $prev_num_nets " current : " $num_nets
        sleep 60
    done
done
