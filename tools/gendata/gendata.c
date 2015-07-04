#include <stdio.h>

/*
	Small program to generate sample data
	Output is the rownumber, a tab and the 10 byte data based on 10 different values
*/

int main(int argc, char **argv) {

	// define pointer as array to char(array)
	const char *p[10];
	p[0] = "abcdefghij";
	p[1] = "ABCDEFGHIJ";
	p[2] = "klmnopqrst";
	p[3] = "KLMNOPQRST";
	p[4] = "uvwxyzäöüß";
	p[5] = "UVWXYZÄÖÜß";
	p[6] = "0123456789";
	p[7] = "xXxXxXxXxX";
	p[8] = "xxxyyyzzz0";
	p[9] = "XXXYYYZZZ1";
	
	// define number of output lines and set default
	unsigned int count = 30;

	// check if argument given and if number give it to counter
	if (argc == 2) {
		count = atoi(argv[1]);
	}

	unsigned int i;

	for (i=0; i<count; i++) {
		printf("%d\t%s\n", i, p[ (i % 10) ]);
	}

	exit(0);
}
