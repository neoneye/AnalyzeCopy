/*********************************************************************
ac_getmode.m - AnalyzeCopy - get stat64.st_mode from a file
Copyright (c) 2009 - opcoders.com
Simon Strandgaard <simon@opcoders.com>
*********************************************************************/

#include <stdio.h>
#include <sys/stat.h>

int main(int argc, char** argv) {
	if(argc < 2) {
		printf("ac_getmode 1.0\n");
		printf("by Simon Strandgaard <simon@opcoders.com>\n\n");
		printf("  usage:\n  ac_getmode <filename>\n\n\n");
		fflush(stdout);
		return -1;
	}
	
	struct stat st;
	int rc;
	rc = stat(argv[1], &st);
	if(rc == -1) {
		perror("stat");
		return 1;
	}
	
	unsigned int mode = st.st_mode & S_IFMT;
	printf("%07o\n", mode);
	return 0;
}
