/*********************************************************************
ac_mklink_acl.c - AnalyzeCopy - assign ACL to symlink
Copyright (c) 2010 - opcoders.com
Simon Strandgaard <simon@opcoders.com>


Credit to Cédric Luthi for discovered that ACL's aren't copied for symlinks, 
and he figured out that it IS possible by using acl_set_fd_np()
http://0xced.blogspot.com/2009/03/chmod-acl-and-symbolic-links_23.html

Anyways my code is not as fancy as Cédric patch to chmod.
Instead it's just some code that assigns a single ACL to a symlink.

prompt> rm mylink 
prompt> ln -s nonexistingfile mylink
prompt> ls -lOe mylink 
lrwxr-xr-x  1 neoneye  staff  - 15  5 Sep 00:53 mylink -> nonexistingfile
prompt> ./ac_mklink_acl -a mylink 
prompt> ls -lOe mylink 
lrwxr-xr-x+ 1 neoneye  staff  - 15  5 Sep 00:53 mylink -> nonexistingfile
 0: 00000000-0000-0000-0000-000000000000 allow read,write,execute,delete,append,readattr,writeattr,readextattr,writeextattr,readsecurity,writesecurity,chown,limit_inherit

*********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/acl.h>

void print_version() {
	printf("ac_mklink_acl 1.0\n");
}

void print_help() {
	printf("ac_mklink_acl 1.0\n");
	printf("by Simon Strandgaard <simon@opcoders.com>\n\n");
	printf("  usage:\n");
	printf("  ac_mklink_acl -a symlink\n");
	printf("  ac_mklink_acl -h\n");
	printf("  ac_mklink_acl -v\n\n");
	printf("  Option -a means it should assign an ACL to the given symlink.\n");
	printf("  Option -h prints this help.\n");
	printf("  Option -v prints the version info.\n");
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


int main(int argc, char** argv) {
	int mode_a = 0;
	char c = 0;
	while((c = getopt(argc, argv, "hva")) != -1) {
		switch(c) {
		case 'h': print_help(); return 0;
		case 'v': print_version(); return 0;
		case 'a': mode_a++; break; // [a]ssign acl to symlink
		default: print_help(); return 0;
		}
	}
	if(mode_a != 1) {
		printf("ERROR: invalid combination of arguments\n");
		print_help(); 
		return 1;
	}

	// assign a test acl to the given symlink
	if(mode_a) {
		int i = optind;
		for(; i < argc; i++) {
			assign_acl_to_symlink(argv[i]);
		}
		return 0;
	}
	
	print_help(); 
	return 0;
}
