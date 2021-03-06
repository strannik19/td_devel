//#########################################################################
//    tptbinview.c
//    Copyright (C) 2015  Andreas Wenzel (https://github.com/tdawen)
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//#########################################################################


#include "Standards.h"
#include <stdlib.h> //noetig fuer atexit()
#include <ncurses.h>
#include <locale.h>
#include <getopt.h>
#include <ctype.h>
#include "CalcNumberColumns.h"
#include "CursesInitialSetup.h"
#include "MyCurses.h"

int main(int argc, char **argv) {
	//int x, y;

	WINDOW *headerwin;
	WINDOW *linenumwin;
	WINDOW *contentwin;

	int c;
	unsigned short numcols = 0;
	unsigned int i;
	char indicator = 0;
	struct windim work;
	int exit;

	opterr = 0;

	while ((c = getopt (argc, argv, ":c:hi")) != -1) {
		switch (c) {
			case 'c':
				numcols = atoi(optarg);
				break;
			case 'i':
				indicator = 1;
				break;
			case 'h':
				printf("usage: %s [-c numcols] [-i] [-h] filename\n", argv[0]);
				return(1);
				break;
			case ':':
				fprintf (stderr, "Option -%c requires an argument.\n", optopt);
				break;
			case '?':
				if (isprint (optopt))
					fprintf (stderr, "Unknown option '-%c'.\n", optopt);
				else
					fprintf (stderr, "Unknown option character '\\x%x'.\n", optopt);
				return(1);
		}
	}

	FILE *ptr_myfile;
	char *buffer;
	unsigned int rownum = 0;

	for (i = optind; i < argc; i++) {
		if ((ptr_myfile=fopen(argv[i],"r")) == NULL) {
			fprintf(stderr, "Please, provide file in tptbin format!\n");
			return(1);
		} else {
			break;
		}
	}

	// allocate memory for one record
	buffer = (char *)malloc(MAXBUF+1);
	char *p;
	p = buffer;
	if (!buffer) {
		fprintf(stderr, "Memory error!");
		fclose(ptr_myfile);
		return(8);
	}

	// clear buffer
	for (i = 0; i < sizeof(buffer); i++) {
		buffer[i] = 0x00;
	}

	setlocale(LC_CTYPE, "");

	CursesInitialSetup(&work, &headerwin, &linenumwin, &contentwin);

	while (!feof(ptr_myfile)) {

		unsigned short rowlen;
		size_t bytesread;
		int numofcols = 0;

		// read the row len definition from file (2 bytes)
		bytesread = fread(&rowlen, 1, sizeof(rowlen), ptr_myfile);

		if (bytesread == sizeof(rowlen)) {

			// read the row data based on the known length
			bytesread = fread(p, 1, rowlen, ptr_myfile);

			if (bytesread == rowlen) {

				// clear buffer before loading it again
				for (i = 0; i < rowlen; i++) {
					p[i] = 0;
				}

				// calculate here
				numofcols = CalcNumberColumns(buffer, rowlen, indicator, numcols);

				if (numofcols > 0) {
				}

			} else {

				// row len definition in file does not meet actual row len
				fprintf(stderr, "Row %d: Row len definition in file does not meet actual row len\n", rownum);
				exit = 3;
				break;

			}

			rownum++;

		} else {

			// not able to read row len definition in file
			fprintf(stderr, "Row %d: Not able to read row len definition in file\n", rownum);
			exit = 1;
			break;

		}

	}

	fclose(ptr_myfile);
	free(buffer);

	getch();
	return(0);
}
