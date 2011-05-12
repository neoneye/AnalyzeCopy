/*********************************************************************
main.c - AnalyzeCopy - exercise acl on symlinks with /bin/cp 
Copyright (c) 2011 - opcoders.com
Simon Strandgaard <simon@opcoders.com>

if acl on symlinks are preserved then this test should output
TEST SUCCESS: acl is copied correct

however this test fails on my Mac OS X 10.6.6 (10J567) and outputs
TEST FAILED: acl on mylink: 1 0
After the copy has completede I can see that the source symlink has an acl,
but the target symlink doesn't have any acl.
I would have expected it to copy the acl as it is from the source file. 

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
#include <sys/acl.h>
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

void create_symlink(const char* path1, const char* path2) {
	int ret = symlink(path1, path2);
	if(ret != 0) {
        printf("link failed: %s\n", strerror (errno));
		exit(EXIT_FAILURE);
	}
}

void assign_acl_to_symlink(const char* path) {
	int fd = open(path, O_SYMLINK);
	if(fd < 0) {
		perror("open");
		exit(1);
	}

	int count = 1;
	acl_t acl;
	acl_entry_t entry;

	acl = acl_init(count);
	acl_create_entry(&acl, &entry);
	acl_set_tag_type(entry, ACL_EXTENDED_ALLOW);

	acl_permset_t pset;
	acl_get_permset(entry, &pset);
	acl_clear_perms(pset);
	acl_add_perm(pset, ACL_READ_DATA);
	int i;
	for(i=0; i<32; ++i) {
		acl_add_perm(pset, (1<<i));
	}

	acl_flagset_t flags;
	acl_get_flagset_np(entry, &flags);
	acl_clear_flags_np(flags);
	acl_add_flag_np(flags, ACL_ENTRY_LIMIT_INHERIT);

	int rc = acl_set_fd_np(fd, acl, ACL_TYPE_EXTENDED);
	if(rc != 0) {
		perror("acl_set_fd_np");
		exit(1);
	}
	
	acl_free(acl);
	close(fd);
}

int does_it_have_acl(const char* path) {
	acl_t acl = acl_get_link_np(path, ACL_TYPE_EXTENDED);

	acl_entry_t dummy;
	if (acl && acl_get_entry(acl, ACL_FIRST_ENTRY, &dummy) == -1) {
		acl_free(acl);
		acl = NULL;

		return 0; // no ACL
	}

	if(acl == NULL) {
		return 0; // no ACL
	}

	acl_free(acl);
	return 1;
}


void chdir_parent() {
	int ret = chdir("..");
	if(ret != 0) {
        printf("chdir failed: %s\n", strerror(errno));
		exit(EXIT_FAILURE);
	}
}

int main (int argc, const char * argv[]) {
	
	print_cwd();

	// prepare source dir content
	{
		mkdir_source();
		chdir_source();

		create_symlink("nonexisting", "mylink");
		assign_acl_to_symlink("mylink");

		chdir_parent();
	}
	

	// copy content from source dir to target dir
	system("/bin/cp -Rp source target");
	

	// verify target dir content
	{
		int v1 = does_it_have_acl("source/mylink");
		int v2 = does_it_have_acl("target/mylink");
		if((v1 != 1) || (v2 != 1)) {
		    printf("TEST FAILED: acl on mylink: %i %i\n", v1, v2);
		} else {
			printf("TEST SUCCESS: acl is copied correct");
		}
	}

    return EXIT_SUCCESS;
}
