/*********************************************************************
ac_copy.m - AnalyzeCopy - copy files using NSFileManager
Copyright (c) 2009 - opcoders.com
Simon Strandgaard <simon@opcoders.com>
*********************************************************************/
#include <stdio.h>
#include <Foundation/Foundation.h>

int main(int argc, char** argv) {
	if(argc < 3) {
		printf("ac_copy 1.0\n");
		printf("by Simon Strandgaard <simon@opcoders.com>\n\n");
		printf("  usage:\n  ac_copy <srcdir> <destdir>\n\n\n");
		fflush(stdout);
		return -1;
	}
	
	[[NSAutoreleasePool alloc] init];

	NSString* src = [NSString stringWithUTF8String:argv[1]];
	NSString* dest = [NSString stringWithUTF8String:argv[2]];
	
	NSFileManager* fm = [NSFileManager defaultManager];
	NSError* err = nil;
	BOOL ok = [fm copyItemAtPath:src toPath:dest error:&err];
	if(!ok) {
		NSLog(@"%@", err);
		return 1;
	}
	return 0;
}
