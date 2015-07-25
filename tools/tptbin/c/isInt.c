//#########################################################################
//    isInt.c
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


#include "isInt.h"
#include <ctype.h>
#include <string.h>
#include "Standards.h"

int isInt(char *p) {
	int isInt = 0;
	int i = 0;

	while(i < strlen(p) && isInt == 0) {
		if (!isdigit(*p))
			return(1);
		i++;
	}

	return(isInt);
}
