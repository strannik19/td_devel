#include <stdlib.h>
#include <unistd.h>

//#########################################################################
//    sbitwrapper.c
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


int main( int argc, char** argv )
{
    // The uid will be uid of original user and the euid will be root (ie 0). Bash
    // scripts don't necessarly use the euid, so we'll setuid full to root.
    // Since the euid is 0, we can setuid to 0.
    //
    // alternativly we can start the script with "#! /bin/bash -p" to force posix mode
    setuid( 0 );

    // shouldn't have to do this, but for consistancy we might as well. And to
    // be sure to be sure
    seteuid( 0 );

    // replace the current programme with this programme, the return value of
    // this C programme is set to the return value of this script.
    // You should use the full path here, since the current directory can be changed by the caller, opening a security risk.
    execl( "/path/to/script.sh", "script.sh", argv[1], 0 );

    // this is never executed.
    return 1;
}
