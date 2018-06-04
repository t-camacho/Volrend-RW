#include <papi.h>
#include <stdio.h>
#include <cstdlib>

static int event_set = PAPI_NULL;
static const int qtd_events = 13;	// length ofvector below
static int events[] = {
	PAPI_L1_DCM,	// Level 1 data cache misses
	PAPI_L1_ICM,	// Level 1 instructions cache misses
	PAPI_L2_DCM,	// Level 2 data cache misses
	PAPI_L2_ICM,	// Level 2 instructions cache misses
	PAPI_L1_TCM,	// Level 1 total cache misses
	PAPI_L2_TCM,	// Level 2 total cache misses
	PAPI_L2_ICA,	// L2 instruction cache accesses
	PAPI_L3_DCA,	// L3 data cache accesses
	PAPI_L3_ICA,	// L3 instruction cache accesses
	PAPI_L3_TCA,	// L3 total cache accesses
	PAPI_L2_ICR,	// L2 instruction cache reads
	PAPI_L3_ICR,	// L3 instruction cache reads
	PAPI_TOT_INS,	// Total instructions executed
};
static const char* messages[] = {
	"Level 1 data cache misses: %lld\n",
	"Level 1 instructions cache misses: %lld\n",
	"Level 2 data cache misses: %lld\n",
	"Level 2 instructions cache misses: %lld\n",
	"Level 1 total cache misses: %lld\n",
	"Level 2 total cache misses: %lld\n",
	"L2 instruction cache accesses: %lld\n",
	"L3 data cache accesses: %lld\n",
	"L3 instruction cache accesses: %lld\n",
	"L3 total cache accesses: %lld\n",
	"L2 instruction cache reads: %lld\n",
	"L3 instruction cache reads: %lld\n",
	"Total instructions executed: %lld\n",
};

class PAPI_CONFIG {
	long_long values[qtd_events];	// vector to store counting results

public:
	void init() {
		int ret;
		if ((ret = PAPI_library_init(PAPI_VER_CURRENT)) != PAPI_VER_CURRENT) {
			fprintf(stderr, "Error: could not initialize PAPI library\n");
			fprintf(stderr, "\tError code: %d\n\t%s\n", ret, PAPI_strerror(ret));
			exit(-1);
		}
		if ((ret = PAPI_create_eventset(&event_set)) != PAPI_OK) {
			fprintf(stderr, "Error: could not create event set\n");
			fprintf(stderr, "\tError code: %d\n\t%s\n", ret, PAPI_strerror(ret));
			exit(-1);
		}
		for(int e = 0; e < qtd_events; e++) {
			if ((ret = PAPI_add_event(event_set, events[e])) != PAPI_OK) {
				fprintf(stderr, "Error: could not add event %d\n", e);
				fprintf(stderr, "\tError code: %d\n\t%s\n", ret, PAPI_strerror(ret));
				exit(-1);
			}
		}
	}
	
	// allows each thread to have its own counters
	void thread_support() {
		int ret;
		if ((ret = PAPI_thread_init(pthread_self)) != PAPI_OK) {
			fprintf(stderr, "Error: could not enable thread support\n");
			fprintf(stderr, "\tError code: %d\n\t%s\n", ret, PAPI_strerror(ret));
			exit(-1);
		}
	}

	void start() {
		int ret;
		if ((ret = PAPI_start(event_set)) != PAPI_OK) {
			fprintf(stderr, "Error: could not start events couting\n");
			fprintf(stderr, "\tError code: %d\n\t%s\n", ret, PAPI_strerror(ret));
			exit(-1);
		}
	}

	void stop() {
		int ret;
		if ((ret = PAPI_stop(event_set, values)) != PAPI_OK) {
			fprintf(stderr, "Error: could not get count values\n");
			fprintf(stderr, "\tError code: %d\n\t%s\n", ret, PAPI_strerror(ret));
			exit(-1);
		}
	}

	void reset() {
		int ret;
		if ((ret = PAPI_reset(event_set)) != PAPI_OK) {
			fprintf(stderr, "Error: could not reset counters\n");
			fprintf(stderr, "\tError code: %d\n\t%s\n", ret, PAPI_strerror(ret));
			exit(-1);
		}
	}

	void print(bool with_thread = false) {
		if (with_thread) {
			unsigned long int id = PAPI_thread_id();
			if (id == (unsigned long int) -1) {
				fprintf(stderr, "Error: could not get thread id\n");
				exit(-1);
			}
			printf("\t\tThread %lud:\n\n", id);
		}
		for (int e = 0; e < qtd_events; e++) {
			printf(messages[e], values[e]);
		}
		printf("\n");
	}
};
