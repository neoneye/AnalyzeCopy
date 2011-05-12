/*********************************************************************
main.c - AnalyzeCopy - exercise birthtime with /bin/cp 
Copyright (c) 2011 - opcoders.com
Simon Strandgaard <simon@opcoders.com>

if birthtime on files are preserved then this test should output
TEST SUCCESS: birthtime is copied correct, birthtime is the same

however this test fails on my Mac OS X 10.6.6 (10J567) and outputs
TEST FAILED: birthtime on myfile differs
I can see that the "cp" command has set the birthtime for myfile to "now",
I would have expected it to copy the birthtime from the source file. 

prompt> GetFileInfo -d source/myfile
01/01/2001 01:01:00
prompt> GetFileInfo -d target/myfile
05/12/2011 07:37:28

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

void create_symlink(const char* path1, const char* path2) {
	int ret = symlink(path1, path2);
	if(ret != 0) {
        printf("link failed: %s\n", strerror (errno));
		exit(EXIT_FAILURE);
	}
}

void chdir_parent() {
	int ret = chdir("..");
	if(ret != 0) {
        printf("chdir failed: %s\n", strerror(errno));
		exit(EXIT_FAILURE);
	}
}

struct timespec get_birthtime(const char* path) {
	
	struct attrlist attrlist;
	struct {
		u_int32_t length;
		struct timespec ts;
	} attrbuf;
	int err;

	bzero(&attrlist, sizeof(attrlist));
	attrlist.bitmapcount = ATTR_BIT_MAP_COUNT;
	attrlist.commonattr  = ATTR_CMN_CRTIME;
    err = getattrlist(
		path, 
		&attrlist, 
		&attrbuf, 
		sizeof(attrbuf), 
		FSOPT_NOFOLLOW
	);
    if(err != 0) {
		perror("getattrlist");
		exit(EXIT_FAILURE);
    }
	if(attrbuf.length != sizeof(attrbuf)) {
		printf("ERROR: getattrlist failed to get birthtime\n");
		exit(EXIT_FAILURE);
	}
	return attrbuf.ts;
}

int main (int argc, const char * argv[]) {
	
	print_cwd();

	// prepare source dir content
	{
		mkdir_source();
		chdir_source();

		create_file("myfile");
		system("/usr/bin/SetFile -d 01/01/2001 myfile");

		chdir_parent();
	}
	

	// copy content from source dir to target dir
	system("/bin/cp -Rp source target");
	

	// verify target dir content
	{
		struct timespec t1 = get_birthtime("source/myfile");
		struct timespec t2 = get_birthtime("target/myfile");
		if((t1.tv_sec != t2.tv_sec) || (t1.tv_nsec != t2.tv_nsec)) {
		    printf("TEST FAILED: birthtime on myfile differs\n");
		} else {
			printf("TEST SUCCESS: birthtime is copied correct, birthtime is the same");
		}
	}

    return EXIT_SUCCESS;
}
