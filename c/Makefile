CC=gcc
CFLAGS=-g -Wall
LDFLAGS=`pkg-config --cflags --libs`

all: cat count_spaces endian getchar input opts pointers pwd sSs steps_compilation sudoku time_waiting_baton time_waiting_percentaje types valid_chars allocating_memory promedios_cruzados

clean:
	find . -type f -a -not -iname "*.c" -a -not -iname "make*" -exec rm -rf '{}' \; -exec echo rm -rf '{}' \;

zipit:
	zip -r files.zip Makefile cat.c count_spaces.c endian.c getchar.c input.c opts.c pointers.c pwd.c sSs.c steps_compilation.c sudoku.c time_waiting_baton.c time_waiting_percentaje.c types.c valid_chars.c allocating_memory.c promedios_cruzados.c
