#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color

while getopts a:d:h: flag
do
    case "${flag}" in
        a) algoname=${OPTARG};;
        d) datasize=${OPTARG};;
        h) host=${OPTARG};;
    esac
done


if [ -z "$algoname" ]
then
    printf "${RED} No algoname given ${NC}\n"
    exit 0
fi

if [ -z "$datasize" ]
then
    printf "${RED} No datasize given ${NC}\n"
    exit 0
fi

# if [ -z $host ] 
# then
#     printf "${RED} No host given. Please give one of master|slave1|slave2 as -host${NC}\n"
#     exit 0
# fi

outputfile="${algoname}_${datasize}";
# echo "Output file: ${outputfile}"

get_metrics () {
    outputfile=$1
    cd ~
    [ -d ~/results ] || mkdir ~/results
    [ -d ~/results/logs ] || mkdir ~/results/logs

    now=$(date +%Y%m%d_%H:%M)

    sparkPID=$(jps | awk '$2 == "SparkSubmit" { printf "%s", $1 }');
    echo "Spark submit running with pid -> $sparkPID" >> ~/results/logs/${outputfile}.log

    workerPID=$(jps | awk '$2 == "Worker" { printf "%s", $1 }');
    echo "Woker running with pid -> $workerPID" >> ~/results/logs/${outputfile}.log

    echo "Saving results on ~/results/${outputfile}_${HOSTNAME}.txt ..."  >> ~/results/logs/${outputfile}.log

    # echo "WRITTEN HERE" &> ~/results/${outputfile}_${HOSTNAME}.txt

    pidstat -h -r -u -v -p $sparkPID,$workerPID 5 &> ~/results/$outputfile\_$HOSTNAME.txt
}

trap ctrl_c INT

function ctrl_c() {
    printf "\n STOPPING MEASURING ON MASTER... \n"
    pkill pidstat

    printf "\n STOPPING MEASURING ON SLAVE1... \n"
    ssh user@slave1 "pkill pidstat"

    printf "\n STOPPING MEASURING ON SLAVE2... \n"
    ssh user@slave2 "pkill pidstat"

    # if [ $host == "slave1" ]; then
    #     ssh user@slave1 "pkill pidstat"
    # elif [ $host == "slave2" ]; then
    #     ssh user@slave2 "pkill pidstat"
    # fi
    # printf "\n STOPPING MEASURING ON $host \n"
    exit 0;
}


echo "MEASURING ON MASTER..."
get_metrics "$outputfile" &

echo "MEASURING ON SLAVE1..."
ssh user@slave1 "$(typeset -f get_metrics); get_metrics \"$outputfile\"" &

echo "MEASURING ON SLAVE2..."
ssh user@slave2 "$(typeset -f get_metrics); get_metrics \"$outputfile\"" &


sparkPID=$(jps | awk '$2 == "SparkSubmit" { printf "%s", $1 }');

while true;
do
    [ -z "$(ps -o state= -p $sparkPID)" ] && ctrl_c
done

