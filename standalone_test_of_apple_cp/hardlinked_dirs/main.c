/*********************************************************************
main.c - AnalyzeCopy - exercise hardlinked dirs with /bin/cp 
Copyright (c) 2011 - opcoders.com
Simon Strandgaard <simon@opcoders.com>

if hardlinked dirs are preserved then this test should output
TEST SUCCESS: hardlinked dirs are copied correct, inodes the same

however this test fails on my Mac OS X 10.6.6 (10J567) and outputs
TEST FAILED: hardlinked dirs are not copied correct, inodes differs: 30542758 30542761

*********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>

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

void create_hardlink(const char* path1, const char* path2) {
	int ret = link(path1, path2);
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

ino_t get_inode(const char* filename) {
	struct stat buf;
	int ret = stat(filename, &buf);
	if(ret != 0) {
        printf("stat failed: %s\n", strerror(errno));
		exit(EXIT_FAILURE);
	}
	return buf.st_ino;
}


int main (int argc, const char * argv[]) {
	
	print_cwd();

	// prepare source dir content
	{
		mkdir_source();
		chdir_source();
		
		mkdir("dir1", 0755);
		mkdir("dir1/subdir", 0755);
		mkdir("dir2", 0755);
		create_hardlink("dir1/subdir", "dir2/subdir");
		create_file("dir1/subdir/file1");

		chdir_parent();
	}
	

	// copy content from source dir to target dir
	system("/bin/cp -Rp source target");
	

	// verify target dir content
	{
		ino_t i1 = get_inode("target/dir1/subdir");
		ino_t i2 = get_inode("target/dir2/subdir");
		
		if(i1 != i2) {
		    printf("TEST FAILED: hardlinked dirs are not copied correct, inodes differs: %lli %lli\n", i1, i2);
		} else {
			printf("TEST SUCCESS: hardlinked dirs are copied correct, inodes the same");
		}
	}

    return EXIT_SUCCESS;
}
