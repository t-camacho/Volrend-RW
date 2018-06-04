#pragma once
#include <pthread.h>
#include <semaphore.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include "const.h"

#define PAD 256

struct GlobalMemory {
    long Index, Counter;
    long Queue[MAX_NUMPROC+1][PAD];
    pthread_barrier_t SlaveBarrier;
    pthread_barrier_t TimeBarrier;
};
