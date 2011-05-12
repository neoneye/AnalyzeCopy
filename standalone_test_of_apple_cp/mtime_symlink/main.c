/*********************************************************************
main.c - AnalyzeCopy - exercise mtime on symlinks with /bin/cp 
Copyright (c) 2011 - opcoders.com
Simon Strandgaard <simon@opcoders.com>

if mtime on symlinks are preserved then this test should output
TEST SUCCESS: mtime is copied correct, mtime is the same

however this test fails on my Mac OS X 10.6.6 (10J567) and outputs
TEST FAILED: timestamp on mylink differs
I can see that the "cp" command has set the mtime for mylink to "now",
I would have expected it to copy the mtime from the source file. 

*********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/time.h>
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

struct timespec get_mtime(const char* filename) {
	struct stat buf;
	int ret = lstat(filename, &buf);
	if(ret != 0) {
        printf("lstat failed: %s\n", strerror(errno));
		exit(EXIT_FAILURE);
	}
	return buf.st_mtimespec;
}

int main (int argc, const char * argv[]) {
	
	print_cwd();

	// prepare source dir content
	{
		mkdir_source();
		chdir_source();

		create_file("myfile");
		create_symlink("myfile", "mylink");
		
		system("/usr/bin/SetFile -P -m 11/11/2011 mylink");
		system("/usr/bin/SetFile -m 01/01/2001 myfile");

		chdir_parent();
	}
	

	// copy content from source dir to target dir
	system("/bin/cp -Rp source target");
	

	// verify target dir content
	{
		int ok = 1;
		
		{
			struct timespec t1 = get_mtime("source/myfile");
			struct timespec t2 = get_mtime("target/myfile");
			if((t1.tv_sec != t2.tv_sec) || (t1.tv_nsec != t2.tv_nsec)) {
			    printf("TEST FAILED: timestamp on myfile differs\n");
				ok = 0;
			}
		}
		{
			struct timespec t1 = get_mtime("source/mylink");
			struct timespec t2 = get_mtime("target/mylink");
			if((t1.tv_sec != t2.tv_sec) || (t1.tv_nsec != t2.tv_nsec)) {
			    printf("TEST FAILED: timestamp on mylink differs\n");
				ok = 0;
			}
		}
		
		if(ok) {
			printf("TEST SUCCESS: mtime is copied correct, mtime is the same");
		}
	}

    return EXIT_SUCCESS;
}
