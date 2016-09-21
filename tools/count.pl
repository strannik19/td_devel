#!/bin/perl -w

##########################################################################
#    count.pl
#    Copyright (C) 2015  Andreas Wenzel (https://github.com/tdawen)
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


################################################################################
#
# Reads from stdin or filename as argument an counts every unqiue occurrence
#
################################################################################
#
# In SQL it looks like:
# select COMPLETE_ROW_FROM_FILE, count(*)
# from FILE
# group by COMPLETE_ROW_FROM_FILE;
#
# With an additional summary line!
#
################################################################################

# Predefine variables with values
my $len_s = 5;
my $len_i = 0;
my $sum = 0;

# Read stdin or file(s) and put every line into hash "%va"
while (<>) {
	chomp;
	$va{$_}++;
	$sum++;
}

# Save the maximum detected line length in $len_s
# Save the maximum detected length of count number in $len_i
foreach (keys %va) {
	$len_s = length($_) if ($len_s < length($_));
	$len_i = length($va{$_}) if ($len_i < length($va{$_}));
}

# Also take length of total count into length consideration
# This gives the number of digits the value in $sum requires
$len_i = length($sum) if ($len_i < length($sum));

# Now, print all elements of hash %va per line with number of occurrence
foreach (keys %va) {
	printf("%-${len_s}s %${len_i}i\n", $_, $va{$_});
}

# Now, print the total summary line
printf("%+${len_s}s %-${len_i}i\n", "total", $sum);
