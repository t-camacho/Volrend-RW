#!/bin/bash

dir=$PWD
EXECUTIONS=1
files=("p_semaphore" "p_trans" "thread_mutex" "thread_spin" "thread_semaphore" 
        "thread_trans" "tbb")
caminhoPIN="$HOME/Downloads/pin-3.6-97554-g31f0a167d-gcc-linux"
mkdir -p output

path="progs/sequential"
cd $path
for ((i=1;i<=${EXECUTIONS};i++)); do
	echo -e "\n--> sequential $i/${EXECUTIONS}\n\n"
	(${caminhoPIN}/pin -t ${caminhoPIN}/source/tools/Memory/obj-intel64/allcache.so -- ./build/app/main -i native) 2>> ../../output/pin_sequential.txt
    
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
                	(${caminhoPIN}/pin -t ${caminhoPIN}/source/tools/Memory/obj-intel64/allcache.so -- ./build/app/main -i native -n $t) 2>> ../../output/pin_${element}_${t}_threads.txt
            	fi
        	else
            	echo -e "\n--> $element ($t flows) $i/${EXECUTIONS}\n"
                	(${caminhoPIN}/pin -t ${caminhoPIN}/source/tools/Memory/obj-intel64/allcache.so -- ./build/app/main -i native -n $t) 2>> ../../output/pin_${element}_${t}_threads.txt
        	fi
		done
    done
	cd -
done
