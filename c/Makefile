CC=gcc
CFLAGS=-g -Wall
LD_FLAGS=`pkg-config --cflags --libs`

all: cat count_spaces endian getchar input opts pointers pwd sSs steps_compilation sudoku sync time_waiting_baton time_waiting_percentaje touch types valid_chars allocating_memory promedios_cruzados

cat: cat.c
	$(CC) $(CFLAGS) $(LD_FLAGS) cat.c -o cat

count_spaces: count_spaces.c
	$(CC) $(CFLAGS) $(LD_FLAGS) count_spaces.c -o count_spaces

endian: endian.c
	$(CC) $(CFLAGS) $(LD_FLAGS) endian.c -o endian

getchar: getchar.c
	$(CC) $(CFLAGS) $(LD_FLAGS) getchar.c -o getchar

input: input.c
	$(CC) $(CFLAGS) $(LD_FLAGS) input.c -o input

opts: opts.c
	$(CC) $(CFLAGS) $(LD_FLAGS) opts.c -o opts

pointers: pointers.c
	$(CC) $(CFLAGS) $(LD_FLAGS) pointers.c -o pointers

pwd: pwd.c
	$(CC) $(CFLAGS) $(LD_FLAGS) pwd.c -o pwd

sSs: sSs.c
	$(CC) $(CFLAGS) $(LD_FLAGS) sSs.c -o sSs

steps_compilation: steps_compilation.c
	$(CC) $(CFLAGS) $(LD_FLAGS) steps_compilation.c -o steps_compilation

sudoku: sudoku.c
	$(CC) $(CFLAGS) $(LD_FLAGS) sudoku.c -o sudoku

sync: sync.c
	$(CC) $(CFLAGS) $(LD_FLAGS) sync.c -o sync

time_waiting_baton: time_waiting_baton.c
	$(CC) $(CFLAGS) $(LD_FLAGS) time_waiting_baton.c -o time_waiting_baton

time_waiting_percentaje: time_waiting_percentaje.c
	$(CC) $(CFLAGS) $(LD_FLAGS) time_waiting_percentaje.c -o time_waiting_percentaje

touch: touch.c
	$(CC) $(CFLAGS) $(LD_FLAGS) touch.c -o touch

types : types.c
	$(CC) $(CFLAGS) $(LD_FLAGS) types.c -o types

valid_chars: valid_chars.c
	$(CC) $(CFLAGS) $(LD_FLAGS) valid_chars.c -o valid_chars

allocating_memory: allocating_memory.c
	$(CC) $(CFLAGS) $(LD_FLAGS) allocating_memory.c -o allocating_memory
	
promedios_cruzados: promedios_cruzados.c
	$(CC) $(CFLAGS) $(LD_FLAGS) promedios_cruzados.c -o promedios_cruzados

clean:
	find . -type f -a -not -iname "*.c" -a -not -iname "make*" -exec rm -rf '{}' \; -exec echo rm -rf '{}' \;

zipit:
	zip -r files.zip Makefile cat.c count_spaces.c endian.c getchar.c input.c opts.c pointers.c pwd.c sSs.c steps_compilation.c sudoku.c sync.c time_waiting_baton.c time_waiting_percentaje.c touch.c types.c valid_chars.c allocating_memory.c promedios_cruzados.c
