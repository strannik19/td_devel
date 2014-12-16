/*
	Copyright (c) 2014 Andreas Wenzel, Teradata Germany
	License: You are free to use and adopt this program for your particular 
	purpose if you are a Teradata customer with a valid Teradata RDBMS license. 
	If you are a Teradata employee you are free to use, copy, and distribute 
	this program to Teradata customers. If you are a Teradata employee you 
	are also free to modify this program but, you must retain the above 
	copyright line and this license statement.
	It is appreciated, if any changes to the source code are reported
	to the copyright holder.
*/

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
