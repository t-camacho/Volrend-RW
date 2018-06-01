#!/bin/bash

TIMEFORMAT=%R
dir=$PWD
files=("p_semaphore" "p_trans" "thread_mutex" "thread_spin" "thread_semaphore" 
        "thread_trans" "tbb")

mkdir output

echo -e "\n--> sequential\n"
path="$dir/progs/sequential"
cd $path
(time ./build/app/main -i native) 2>> $dir/output/sequential.o

for i in 2 4 8 16
do
    for element in ${files[@]}
    do
        if [ "$element" = "tbb" ]
        then
            if [ "$i" -le "4" ]
            then
                echo -e "\n--> $element with $i\n"
                path=$dir/"progs"/$element
                cd $path
                (time ./build/app/main -i native -n $i) 2>> $dir/output/result$i.o
            fi
        else 
            echo -e "\n--> $element with $i\n"
            path=$dir/"progs"/$element
            cd $path
            (time ./build/app/main -i native -n $i) 2>> $dir/output/result$i.o
        fi
    done   
done

