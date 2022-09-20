#!/bin/bash

while getopts d: flag
do
    case "${flag}" in
        d) directory=${OPTARG};;
    esac
done

for file in $directory**/*.txt; do 
    path=$(dirname $file)
    filename=$(echo $file | sed 's/.txt//g' | awk -F'/' '{ print $NF }') 

    cat $file |
    sed -e 's/#//g' | # remove # character
    awk '(NR>1) { print $0 }' | # remove 1st line
    awk '/[0-9]/ { print $0 }' | # remove title
    awk '
        BEGIN {
            first_row = 0; 
            start_time=""
        } { 
            if (first_row == 0) {
                first_row=NF;
                start_time=$1;
            }; 
            if (NR%2==0) { 
                print "Worker", $1-start_time, $7
            } else { 
                print "ClusterManager", $1-start_time, $7 
            }
        }' > /tmp/result.tmp

        [ -d ${path}/results ] || mkdir ${path}/results/

        echo "Time, CPU %" > ${path}/results/${filename}_CM.csv
        cat /tmp/result.tmp | grep ClusterManager | awk -F' ' '{ print $2,", ",$3 }' | sed -e 's/ , /,/g' >> ${path}/results/${filename}_CM.csv


        echo "Time, CPU %" > ${path}/results/${filename}_WR.csv
        cat /tmp/result.tmp | grep Worker | awk -F' ' '{ print $2,", ",$3 }' | sed -e 's/ , /,/g' >> ${path}/results/${filename}_WR.csv
done