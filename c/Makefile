CC=gcc
CFLAGS=-g -Wall
LDFLAGS=`pkg-config --cflags --libs`

all: cat count_spaces endian getchar input opts pointers pwd sSs steps_compilation sudoku time_waiting_baton time_waiting_percentaje types valid_chars allocating_memory promedios_cruzados monkey_typewriter

native: CFLAGS=-O3 -march=native -Wall
native: all

clean:
	find . -type f -a -not -iname "*.c" -a -not -iname "make*" -exec rm -rf '{}' \; -exec echo rm -rf '{}' \;

zipit:
	zip -r files.zip Makefile *.c
