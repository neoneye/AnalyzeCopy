/*********************************************************************
ac_bkuptime.m - AnalyzeCopy - set/get ATTR_CMN_BKUPTIME
Copyright (c) 2009 - opcoders.com
Simon Strandgaard <simon@opcoders.com>
*********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/attr.h>
#include <time.h>

void print_version() {
	printf("ac_bkuptime 1.0\n");
}

void print_help() {
	printf("ac_bkuptime 1.0\n");
	printf("by Simon Strandgaard <simon@opcoders.com>\n\n");
	printf("  usage:\n");
	printf("  ac_bkuptime -r file\n");
	printf("  ac_bkuptime -w timestamp file\n");
	printf("  ac_bkuptime -h\n");
	printf("  ac_bkuptime -v\n\n");
	printf("  Option -r means it should read the backup timestamp.\n");
	printf("  Option -w means it should write the backup timestamp.\n");
	printf("  Option -h prints this help.\n");
	printf("  Option -v prints the version info.\n");
}


/*
read the backup timestamp from the file
*/
void read_timestamp(const char* filename) {
	struct attrlist alist;
	struct {
		u_int32_t length;
		struct timespec ts;
	} buf;
	int err;

	bzero(&alist, sizeof(alist));
	alist.bitmapcount = ATTR_BIT_MAP_COUNT;
	alist.commonattr  = ATTR_CMN_BKUPTIME;
    err = getattrlist(
		filename, 
		&alist, 
		&buf, 
		sizeof(buf), 
		FSOPT_NOFOLLOW
	);
    if(err != 0) {
		perror("getattrlist");
		exit(1);
    }
	if(buf.length != sizeof(buf)) {
		printf("ERROR: failed to obtain backuptime\n");
		exit(1);
	}

	// format the date as: 2001_12_28_23_59_59
	time_t t = buf.ts.tv_sec;
	struct tm tm;
    localtime_r(&t, &tm);
	char str[50];
	strftime(str, 50, "%Y_%m_%d_%H_%M_%S", &tm);
	puts(str);
	
	exit(0);
}


/*
write the backup timestamp to the file
*/
void write_timestamp(const char* timestamp_str, const char* filename) {
	// printf("write_timestamp: %s  %s\n", timestamp_str, filename);

	struct tm tm;
	time_t t;

	// YYYY_mm_dd_HH_MM_SS = "2001_12_28_23_59_59"
	if(strptime(timestamp_str, "%Y_%m_%d_%H_%M_%S", &tm) == NULL) {
		printf("ERROR in strptime. Timestamp must be like:\n2001_12_28_23_59_59\n");
		exit(1);
	}

/*	printf("year: %d; month: %d; day: %d;\n",
	        tm.tm_year, tm.tm_mon, tm.tm_mday);
	printf("hour: %d; minute: %d; second: %d\n",
	        tm.tm_hour, tm.tm_min, tm.tm_sec);
	printf("week day: %d; year day: %d\n", tm.tm_wday, tm.tm_yday); */


	tm.tm_isdst = -1;      /* Not set by strptime(); tells mktime()
	                          to determine whether daylight saving time
	                          is in effect */
	t = mktime(&tm);
	if(t == -1) {
		printf("ERROR in mktime. Timestamp must be like:\n2001_12_24_12_33_45\n");
		exit(1);
	}
	// printf("seconds since the Epoch: %ld\n", (long) t);


	struct timespec ts;
	ts.tv_sec = t;
	ts.tv_nsec = 0;

	struct attrlist alist;
	int err;

	bzero(&alist, sizeof(alist));
	alist.bitmapcount = ATTR_BIT_MAP_COUNT;
	alist.commonattr  = ATTR_CMN_BKUPTIME;
    err = setattrlist(
		filename, 
		&alist, 
		&ts, 
		sizeof(ts), 
		FSOPT_NOFOLLOW
	);
    if(err != 0) {
		perror("setattrlist");
		exit(1);
    }

	printf("OK\n");
}


int main(int argc, char** argv) {
	int mode_r = 0, mode_w = 0;
	char c = 0;
	while((c = getopt(argc, argv, "hvrw")) != -1) {
		switch(c) {
		case 'h': print_help(); return 0;
		case 'v': print_version(); return 0;
		case 'r': mode_r++; break; // [r]ead timestamp
		case 'w': mode_w++; break; // [w]rite timestamp
		default: print_help(); return 0;
		}
	}
	if(mode_r + mode_w != 1) {
		printf("ERROR: invalid combination of arguments\n");
		print_help(); 
		return 1;
	}

	// read the backup timestamp from the file
	if(mode_r) {
		int i = optind;
		for(; i < argc; i++) {
			read_timestamp(argv[i]);
		}
		return 0;
	}
	
	// write the backup timestamp to the file
	if(mode_w) {
		int i = optind + 1;
		for(; i < argc; i++) {
			write_timestamp(argv[optind], argv[i]);
		}
		return 0;
	}
	
	print_help(); 
	return 0;
}
