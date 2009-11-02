#!/usr/bin/perl -w
#
# for this script to work you must have File::Copy::Recursive
# module installed. You can install it like this:
#
#  sudo perl -MCPAN -e 'install File::Copy::Recursive'
#
#
use File::Copy::Recursive qw(dircopy);

local $n = $#ARGV;

if($n != 1) {
	print "ac_perl_copy 1.0\n";
	print "by Simon Strandgaard <simon\@opcoders.com>\n\n";
	print "  usage:\n  ac_perl_copy <srcdirglob> <destdir>\n\n";
	print "  example:\n  ./ac_perl_copy \"/tmp/a/*\" \"/tmp/bar\"\n\n\n";
	if($n == -1) {
		exit 0;
	}
	die 1;
}

local $copy_from = $ARGV[0];
local $copy_to = $ARGV[1];

local $File::Copy::Recursive::SkipFlop = 1;
dircopy($copy_from, $copy_to) or die $!;
#dircopy('/tmp/a/*', '/tmp/bar') or die $!;

exit 0;
