//#########################################################################
//    tptbinrc.c
//    Copyright (C) 2015  Andreas Wenzel (https://github.com/awenny)
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
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char **argv) {

	char *filename;
	filename = NULL;
	int i = 0;
	int sumrowcount = 0;
	int readerror = 0;
	int filecount = 0;

	unsigned short rowlen;

	char *buffer;
	buffer = (char *)malloc(MAXBUF+1);
	if (!buffer) {
		fprintf(stderr, "Memory error!");
		return(8);
	}

	if (argc < 2) {

		// no arguments given
		// coming from stdin

		int rowcount = 0;

		while (!feof(stdin)) {

			size_t bytesread;

			// read the row len definition from file (2 bytes)
			bytesread = fread(&rowlen, 1, sizeof(rowlen), stdin);

			if (bytesread == sizeof(rowlen)) {

				// read the row data based on the known length
				bytesread = fread(buffer, 1, rowlen, stdin);

				if (bytesread != rowlen) {
					readerror++;
					break;
				}
			}

			rowcount++;
		}

		printf("%d %s\n", rowcount, "total");

	} else {
 
		// try every argument if it is a file
		for (i=1; i < argc; i++) {

			int rowcount = 0;
			int result = access(argv[i], F_OK);
			if (result == 0) {
				// it is a file
				filename = argv[i];
			} else {
				// argument is not a file, ignore it
				continue;
			}

			FILE *fp;
			fp=fopen(filename, "rb");

			if (!fp) {
				fprintf(stderr, "File open error on %s!\n", filename);
				continue;
			}

			while (!feof(fp)) {

				size_t bytesread;

				// read the row len definition from file (2 bytes)
				bytesread = fread(&rowlen, 1, sizeof(rowlen), fp);

				if (bytesread == sizeof(rowlen)) {

					// read the row data based on the known length
					bytesread = fread(buffer, 1, rowlen, fp);

					if (bytesread != rowlen) {
						readerror++;
						break;
					}
				}

				rowcount++;
			}

			fclose(fp);

			if (readerror == 0) {
				printf("%d %s\n", rowcount, filename);
				filecount++;
				sumrowcount += rowcount;
			}

		}

		if (filecount > 1) {
			printf("%d %s\n", sumrowcount, "total");
		}

	}

	return(0);

}
