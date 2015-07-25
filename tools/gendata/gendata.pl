#!/usr/bin/perl

##########################################################################
#    gendata.pl
#    Copyright (C) 2015  Andreas Wenzel (https://github.com/awenny)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
##########################################################################


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
