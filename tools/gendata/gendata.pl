#!/usr/bin/perl

#	Small program to generate sample data
#	Output is the rownumber, a tab and the 10 byte data based on 10 different values

use strict;
use warnings;

# assign values to array
my @p = (
	 "abcdefghij"
	,"ABCDEFGHIJ"
	,"klmnopqrst"
	,"KLMNOPQRST"
	,"uvwxyzäöüß"
	,"UVWXYZÄÖÜß"
	,"0123456789"
	,"xXxXxXxXxX"
	,"xxxyyyzzz0"
	,"XXXYYYZZZ1"
	);

# define number of output lines and set default
my $count = 30;

# check if argument given and if number give it to counter
if ($#ARGV >= 0) {
	$count = $ARGV[0];
}

my $i;

for ($i = 0; $i < $count; $i++) {
	printf("%d\t%s\n", $i, $p[ ($i % 10) ]);
}

exit(0);
