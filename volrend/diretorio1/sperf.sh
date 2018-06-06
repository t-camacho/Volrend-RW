#!/bin/bash

dir=$PWD
EXECUTIONS=1
files=("p_semaphore" "p_trans" "thread_mutex" "thread_spin" "thread_semaphore" 
        "thread_trans" "tbb")

mkdir -p output

path="progs/sequential"
cd $path
for ((i=1;i<=${EXECUTIONS};i++)); do
	echo -e "\n--> sequential $i/${EXECUTIONS}\n\n"
	(perf stat -e instructions,cycles,mem-loads,mem-stores,cache-misses,dtlb_load_misses.miss_causes_a_walk,itlb_misses.miss_causes_a_walk ./build/app/main -i native) 2>> ../../output/perf_sequential.txt
done
cd -

for element in ${files[@]}; do
	path="progs"/$element
	cd $path
	for t in 2 4 8 16; do
		for ((i=1;i<=${EXECUTIONS};i++)); do
            	    echo -e "\n--> $element ($t flows) $i/${EXECUTIONS}\n"
                    (perf stat -e instructions,cycles,mem-loads,mem-stores,cache-misses,dtlb_load_misses.miss_causes_a_walk,itlb_misses.miss_causes_a_walk ./build/app/main -i native -n $t) 2>> ../../output/perf_${element}_${t}_threads.txt
		done
    done
	cd -
done
