//#########################################################################
//    CursesInitialSetup.c
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
#include "MyCurses.h"
#include "quit.h"

void CursesInitialSetup(struct windim *work, WINDOW *headerwin, WINDOW *linenumwin, WINDOW *contentwin) {
	int screenx, screeny;
	unsigned int i;

	initscr();
	atexit(quit(headerwin, linenumwin, contentwin));

	start_color();
	init_pair(1, COLOR_YELLOW, COLOR_BLUE);
	init_pair(2, COLOR_BLUE, COLOR_WHITE);

	bkgd(COLOR_PAIR(1));

	curs_set(0);

	getmaxyx(stdscr, screeny, screenx);

	work->x = screenx;
	work->y = screeny;

	headerwin = newwin(1, screenx - 5, 0, 5);
	wbkgd(headerwin, COLOR_PAIR(2));

	linenumwin = newwin(screeny - 1, 5, 1, 0);
	wbkgd(linenumwin, COLOR_PAIR(2));

	contentwin = newwin(screeny - 1, screenx - 5, 2, 6);
	wbkgd(contentwin, COLOR_PAIR(1));

	for (i = 0; i < screeny - 1; i++) {
		mvwprintw(linenumwin, i, 0, "%5u\n", i + 1);
	}

	mvwprintw(headerwin, 0, 0, "Test");

	scrollok(linenumwin, TRUE);
	scrollok(contentwin, TRUE);

	refresh();
	wrefresh(linenumwin);
	wrefresh(headerwin);
	wrefresh(contentwin);
}
