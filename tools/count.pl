#!/bin/perl -w

##########################################################################
#    count.pl
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


################################################################################
#
# Reads from stdin or filename as argument an counts every unqiue occurrence
#
################################################################################
#
# In SQL it looks like:
# select COMPLETE_ROW_FROM_FILE, count(*)
# from FILE
# group by COMPLETE_ROW_FROM_FILE
# order by COMPLETE_ROW_FROM_FILE;
#
# With an additional summary line!
#
################################################################################

# Vorbelegung an Variablen
my $len_s = 6;
my $len_i = 0;
my $sum = 0;

# Zähle hier das File durch. Benutze dabei den Hash "%va"
while (<>) {
	chomp;
	$va{$_}++;
}

# Ermittle die maximale Länge an ZEILE_VON_FILE bzw. Anzahl (count(*))
# Dies könnte man in der oberen Schleife machen.
# Aber, weil davon auszugehen ist, daß sehr viele Sätze (mitunter Millionen)
# Eingang finden, und nur wenige am Schluß herauskommen, benutzen wir eine
# eigene Schleife, die am Ergebnis arbeitet.
foreach (keys %va) {
	$len_s = length($_) if ($len_s < length($_));
	$len_i = length($va{$_}) if ($len_i < length($va{$_}));
}

# Beziehe die Summenzeile in die Längenermittlung mit ein.
$len_i = length($sum) if ($len_i < length($sum));

# Hier werden die einzelnen ZEILE_VON_FILE plus Anzahl (count(*)) ausgegeben.
foreach (keys %va) {
	printf("%-${len_s}s %${len_i}i\n", $_, $va{$_});
}

# Und zum Schluß kommt noch die Summenzeile hin.
printf("%+${len_s}s %-${len_i}i\n", "gesamt", $sum);
