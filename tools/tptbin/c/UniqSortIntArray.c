//#########################################################################
//    UniqSortIntArray.c
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


// function to sort array with unsigned int

int UniqSortIntArray (unsigned int numElements, unsigned int *array) {
	unsigned int i, j, k, swapper;

	// dedupe
	for (i = 0; i < numElements; i++) {
		for (j = 0; j < numElements; j++) {
			if (i == j) {
				continue;
			} else if (*(array + i) == *(array + j)) {
				k = j;
				numElements--;
				while (k < numElements) {
					*(array + k) = *(array + k + 1);
					k++;
				}
				j = 0;
			}
		}
	}

	// sort ascending
	for (i = 0; i < numElements; i++) {
		for (j = i + 1; j < numElements; j++) {
			if (*(array + i) > *(array + j)) {
				swapper = *(array + i);
				*(array + i) = *(array + j);
				*(array + j) = swapper;
			}
		}
	}

	return(numElements);

}
