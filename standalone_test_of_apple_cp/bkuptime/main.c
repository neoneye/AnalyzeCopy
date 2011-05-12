/*********************************************************************
main.c - AnalyzeCopy - exercise bkuptime with /bin/cp 
Copyright (c) 2011 - opcoders.com
Simon Strandgaard <simon@opcoders.com>

if bkuptime on files are preserved then this test should output
TEST SUCCESS: bkuptime is copied correct, bkuptime is the same

however this test fails on my Mac OS X 10.6.6 (10J567) and outputs
TEST FAILED: bkuptime on myfile differs
I can see that the "cp" command has set the bkuptime for myfile to 1970 (start of epoch),
I would have expected it to copy the bkuptime from the source file. 

*********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/xattr.h>
#include <sys/attr.h>
#include <fcntl.h>

void print_cwd() {
	char* cwd = getcwd(0, 0);
    if(!cwd) {
        printf("getcwd failed: %s\n", strerror (errno));
		exit(EXIT_FAILURE);
    }
	printf("%s\n", cwd);
	free(cwd);
}

void mkdir_source() {
	int ret = mkdir("source", 0755);
	if(ret != 0) {
        printf("mkdir failed: %s\n", strerror(errno));
		exit(EXIT_FAILURE);
	}
}

void chdir_source() {
	int ret = chdir("source");
	if(ret != 0) {
        printf("chdir failed: %s\n", strerror(errno));
		exit(EXIT_FAILURE);
	}
}

void create_file(const char* filename) {
	FILE* file = fopen(filename, "w");
	fprintf(file, "hello", 0);
	fclose(file);	
}

void chdir_parent() {
	int ret = chdir("..");
	if(ret != 0) {
        printf("chdir failed: %s\n", strerror(errno));
		exit(EXIT_FAILURE);
	}
}

struct timespec get_bkuptime(const char* filename) {
	struct attrlist alist;
	struct {
		u_int32_t length;
		struct timespec ts;
	} buf;

	bzero(&alist, sizeof(alist));
	alist.bitmapcount = ATTR_BIT_MAP_COUNT;
	alist.commonattr  = ATTR_CMN_BKUPTIME;
    int err = getattrlist(
		filename, 
		&alist, 
		&buf, 
		sizeof(buf), 
		FSOPT_NOFOLLOW
	);
    if(err != 0) {
		perror("getattrlist");
		exit(EXIT_FAILURE);
    }
	if(buf.length != sizeof(buf)) {
		printf("ERROR: failed to obtain backuptime\n");
		exit(EXIT_FAILURE);
	}

/*	// format the date as: 2001_12_28_23_59_59
	time_t t = buf.ts.tv_sec;
	struct tm tm;
    localtime_r(&t, &tm);
	char str[50];
	strftime(str, 50, "%Y_%m_%d_%H_%M_%S", &tm);
	puts(str);*/

	return buf.ts;
}


void set_bkuptime(const char* filename, struct timespec ts) {
	struct attrlist alist;
	bzero(&alist, sizeof(alist));
	alist.bitmapcount = ATTR_BIT_MAP_COUNT;
	alist.commonattr  = ATTR_CMN_BKUPTIME;
    int err = setattrlist(
		filename, 
		&alist, 
		&ts, 
		sizeof(ts), 
		FSOPT_NOFOLLOW
	);
    if(err != 0) {
		perror("setattrlist");
		exit(EXIT_FAILURE);
    }
}


int main (int argc, const char * argv[]) {
	
	print_cwd();

	// prepare source dir content
	{
		mkdir_source();
		chdir_source();

		create_file("myfile");

		struct timespec ts;
		ts.tv_sec = 1300000000;
		ts.tv_nsec = 0;
		set_bkuptime("myfile", ts);

		chdir_parent();
	}
	

	// copy content from source dir to target dir
	system("/bin/cp -Rp source target");
	

	// verify target dir content
	{
		struct timespec t1 = get_bkuptime("source/myfile");
		struct timespec t2 = get_bkuptime("target/myfile");
		if((t1.tv_sec != t2.tv_sec) || (t1.tv_nsec != t2.tv_nsec)) {
		    printf("TEST FAILED: bkuptime on myfile differs\n");
		} else {
			printf("TEST SUCCESS: bkuptime is copied correct, bkuptime is the same");
		}
	}

    return EXIT_SUCCESS;
}
