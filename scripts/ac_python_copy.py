#!/usr/bin/python
import sys
import os
import shutil


if (len(sys.argv) != 3):
	print "ac_python_copy.py 1.0"
	print "by Simon Strandgaard <simon@opcoders.com>\n"
	print "  usage:\n  ac_python_copy <srcdir> <destdir>\n"
	if (len(sys.argv) == 1):
		sys.exit(0)
	else:
		sys.exit(1)
	
copy_from = sys.argv[1]
copy_to = sys.argv[2]
#print "copy_from: ", copy_from
#print "copy_to: ", copy_to

shutil.copytree(copy_from, copy_to)

sys.exit(0)
