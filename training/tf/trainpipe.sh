#!/bin/bash

for((i=0; i<1000; i=i+1)) ; do
    latest=$(ls -1c *.txt | head | sed 's/\.txt//g')
    setsid nice python3 parse.py ../../traindata_ ${latest}
done
