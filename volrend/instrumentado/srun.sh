#!/bin/bash

TIMEFORMAT=%R
dir=$PWD
EXECUTIONS=1
files=("p_semaphore" "p_trans" "thread_mutex" "thread_spin" "thread_semaphore" 
        "thread_trans" "tbb")

mkdir output_papi

path="progs/sequential"
cd $path
for ((i=1;i<=${EXECUTIONS};i++)); do
	echo -e "\n--> sequential ($i/${EXECUTIONS})\n"
	./build/app/main -i native >> ../../output_papi/papi_sequential
done
cd -

for element in ${files[@]}; do
	path="progs"/$element
	cd $path
	for t in 2 4 8 16; do
		for ((i=1;i<=${EXECUTIONS};i++)); do
			if [ "$element" = "tbb" ]
        	then
            	if [ "$t" -le "4" ]
            	then
                	echo -e "\n--> $element ($t flows) $i/${EXECUTIONS}\n"
                	./build/app/main -i native -n $t >> ../../output_papi/tempo_${element}_${t}_threads.txt
            	fi
        	else
            	echo -e "\n--> $element ($t flows) $i/${EXECUTIONS}\n"
            	./build/app/main -i native -n $t >> ../../output_papi/tempo_${element}_${t}_threads.txt
        	fi
		done
    done
	cd -
done

