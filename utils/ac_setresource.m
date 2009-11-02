/*********************************************************************
ac_setresource.m - AnalyzeCopy - store data in the resource fork
Copyright (c) 2009 - opcoders.com
Simon Strandgaard <simon@opcoders.com>
*********************************************************************/
#include <stdio.h>
#include <Foundation/Foundation.h>

BOOL set_resource_fork(NSData* data, NSString* path)
{
	FSRef ref;
	OSStatus osstatus = 0;

	osstatus = FSPathMakeRef((const UInt8 *)[path fileSystemRepresentation], &ref, NULL);	
	if(osstatus != 0) {
		printf("ERROR: failed to make FSRef\n");
		return NO;
	}

	HFSUniStr255 fork_name;
	FSGetResourceForkName(&fork_name);
	
	OSErr oserr;

	FSIORefNum ref_num;
	oserr = FSOpenFork(
		&ref,
		fork_name.length, 
		fork_name.unicode,
		fsRdWrPerm,
		&ref_num
	);
	if(oserr != noErr) {
		printf("ERROR: failed to open resourcefork\n");
		return NO;
	}
	
	ByteCount n_write = 0;
	oserr = FSWriteFork(
		ref_num,
		fsFromStart,
		0,
		[data length],
		[data bytes],
		&n_write
	);
	if(oserr != noErr) {
		printf("ERROR: failed to write to resourcefork\n");
		return NO;
	}
	if(n_write != [data length]) {
		printf("ERROR: failed to write all the data\n");
		return NO;
	}
	
	oserr = FSCloseFork(ref_num);
	if(oserr != noErr) {
		printf("ERROR: failed to close resourcefork\n");
		return NO;
	}
	
	return YES;
}


int main(int argc, char** argv) {
	if(argc < 3) {
		printf("ac_setresource 1.0\n");
		printf("by Simon Strandgaard <simon@opcoders.com>\n\n");
		printf("  usage:\n  ac_setresource <srcfile> <destfile>\n\n\n");
		fflush(stdout);
		return -1;
	}
	
	[[NSAutoreleasePool alloc] init];

	NSString* src = [NSString stringWithUTF8String:argv[1]];
	NSString* dest = [NSString stringWithUTF8String:argv[2]];

	NSData* data = [NSData dataWithContentsOfFile:src];
	if(data == nil) {
		printf("ERROR: could not load data.\n");
		return 1;
	}
	if(set_resource_fork(data, dest) == NO) {
		printf("ERROR: could not set resource fork.\n");
		return 1;
	}
	return 0;
}
