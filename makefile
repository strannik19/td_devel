OBJ = tptbincheck.o CalcNumberColumns.o tptbinview.o tptbintestfile.o tptbinslice.o

all: tptbincheck CalcNumberColumns.o tptbinview tptbintestfile

clean:
	rm -rf $(OBJ)

%.o: %.c
	gcc -Wall -g -c $<

tptbincheck: tptbincheck.o CalcNumberColumns.o
	gcc -o tptbincheck tptbincheck.o CalcNumberColumns.o

tptbinview: tptbinview.o
	gcc -o tptbinview tptbinview.o -lncurses

tptbintestfile: tptbintestfile.o
	gcc -o tptbintestfile tptbintestfile.o

tptbinslice: tptbinslice.o
	gcc -o tptbinslice tptbinslice.o
