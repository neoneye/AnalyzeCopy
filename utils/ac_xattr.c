/*********************************************************************
ac_xattr.m - AnalyzeCopy - manipulate extended attributes
Copyright (c) 2009 - opcoders.com
Simon Strandgaard <simon@opcoders.com>
*********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/xattr.h>

void print_version() {
	printf("ac_xattr 1.0\n");
}

void print_help() {
	printf("ac_xattr 1.0\n");
	printf("by Simon Strandgaard <simon@opcoders.com>\n\n");
	printf("  usage:\n");
	printf("  ac_xattr [-s] -l file\n");
	printf("  ac_xattr [-s] -w attr_name attr_value file\n");
	printf("  ac_xattr [-s] -d attr_name file\n");
	printf("  ac_xattr -h\n");
	printf("  ac_xattr -v\n\n");
	printf("  Option -s means it should act on symlinks.\n");
	printf("  Option -l means it should list all xattr entries.\n");
	printf("  Option -w means it should write one xattr entry.\n");
	printf("  Option -d means it should delete one xattr entry.\n");
	printf("  Option -h prints this help.\n");
	printf("  Option -v prints the version info.\n");
}


/*
list all extended attributes for the file
*/
void list_xattr(const char* filename, int nofollow) {
	int options = nofollow ? XATTR_NOFOLLOW : 0;
	ssize_t buffer_size = listxattr(filename, NULL, 0, options);
	if(buffer_size < 0) {
		perror("listxattr");
		exit(1);
	}
	if(buffer_size == 0) {
		// no xattr data
		return;
	}
	
	char* buffer = (char*)malloc(buffer_size);
	size_t n_read = listxattr(filename, buffer, buffer_size, options);
	if(n_read != buffer_size) {
		perror("listxattr (size mismatch)");
		free(buffer);
		exit(1);
	}

	// build a list of name,value,name,value,name,value,...
	int index = 0;
	char* name = buffer;
	for(; name < buffer+buffer_size; name += strlen(name) + 1, index++) {
		int size = getxattr(filename, name, 0, 0, 0, options);
		if(size < 0) {
			perror("getxattr");
			exit(1);
		}

		char* buf2 = (char*)malloc(size + 1);
		int size2 = getxattr(filename, name, buf2, size, 0, options);
		if(size != size2) {
			perror("getxattr (size mismatch)");
			exit(1);
		}
		printf("%s : %s\n", name, buf2);
		free(buf2);
	}	

	free(buffer);
}


/*
add a new extended attributes to the file
*/
void write_xattr(const char* attr_name, const char* attr_value, const char* filename, int nofollow) {
	int rc = setxattr(
		filename,
		attr_name,
		attr_value, 
		strlen(attr_value), 
		0, 
		(nofollow ? XATTR_NOFOLLOW : 0)
	);
	if(rc < 0) { 
		perror("setxattr"); 
		exit(1); 
	}
}


/*
delete one extended attributes from the file
*/
void delete_xattr(const char* attr_name, const char* filename, int nofollow) {
	int rc = removexattr(
		filename, 
		attr_name, 
		(nofollow ? XATTR_NOFOLLOW : 0)
	);
	if(rc < 0) { 
		perror("removexattr"); 
		exit(1); 
	}
}


int main(int argc, char** argv) {
	int mode_l = 0, mode_w = 0, mode_d = 0, flag_s = 0;
	char c = 0;
	while((c = getopt(argc, argv, "hvlwds")) != -1) {
		switch(c) {
		case 'h': print_help(); return 0;
		case 'v': print_version(); return 0;
		case 'l': mode_l++; break; // [l]ist all entries
		case 'w': mode_w++; break; // [w]rite one entry
		case 'd': mode_d++; break; // [d]elete one entry
		case 's': flag_s++; break; // act on [s]ymlink
		default: print_help(); return 0;
		}
	}
	if(mode_l + mode_w + mode_d != 1) {
		printf("ERROR: invalid combination of arguments\n");
		print_help(); 
		return 1;
	}

	// list extended attributes
	if(mode_l) {
		int i = optind;
		for(; i < argc; i++) {
			list_xattr(argv[i], flag_s);
		}
		return 0;
	}
	
	// write extended attribute to file
	if(mode_w) {
		int i = optind + 2;
		for(; i < argc; i++) {
			write_xattr(argv[optind], argv[optind + 1], argv[i], flag_s);
		}
		return 0;
	}
	
	// delete extended attribute from file
	if(mode_d) {
		int i = optind + 1;
		for(; i < argc; i++) {
			delete_xattr(argv[optind], argv[i], flag_s);
		}
		return 0;
	}

	print_help(); 
	return 0;
}
