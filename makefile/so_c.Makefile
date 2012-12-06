# Project: STKm / TSTK
# Makefile for linux
# $ make stkm
# $ make tstk

CPP  = g++
CC   = gcc
#WINDRES = windres.exe
#RES  = 
OBJ = $(BINOBJ) $(TESTOBJ)

OBJ  = ../OBJ/STK.o ../OBJ/TSTK.o $(RES)
BINOBJ  = ../OBJ/STK.o ../OBJ/ESTK.o
TESTOBJ  = ../OBJ/STK.o ../OBJ/UTST.o ../OBJ/TSTK.o
#LIBS =  -L"P:/DevCpp/Dev-CppPortable/App/devcpp/lib"  
INCS =  -I"../"  -I"../INC"
#INCS =  -I"P:/DevCpp/Dev-CppPortable/App/devcpp/include"  -I"Q:/MODULES/STACK"  -I"Q:/MODULES/STACK/INC" 
#CXXINCS =  -I"P:/DevCpp/Dev-CppPortable/App/devcpp/lib/gcc/mingw32/3.4.2/include"  -I"P:/DevCpp/Dev-CppPortable/App/devcpp/include/c++/3.4.2/backward"  -I"P:/DevCpp/Dev-CppPortable/App/devcpp/include/c++/3.4.2/mingw32"  -I"P:/DevCpp/Dev-CppPortable/App/devcpp/include/c++/3.4.2"  -I"P:/DevCpp/Dev-CppPortable/App/devcpp/include"  -I"Q:/MODULES/STACK"  -I"Q:/MODULES/STACK/INC" 
BIN  = ../MAIN/OUT/STKm.out
TEST = ../MAIN/OUT/TSTK.out
CXXFLAGS = $(CXXINCS)  
CFLAGS = $(INCS) -g -Wall
RM = rm -f

.PHONY: all all-before all-after clean clean-custom

all: all-before stkm tstk all-after

stkm: $(BINOBJ)
	$(CC) $(LIBS) $(BINOBJ) -o $(BIN)

tstk: $(TESTOBJ)
	$(CC) $(LIBS) $(TESTOBJ) -o $(TEST)

clean: clean-custom
	${RM} $(OBJ) $(BIN) $(TEST)

../OBJ/STK.o: ../STK/SRC/STK.C
	$(CC) $(CFLAGS) -c ../STK/SRC/STK.C -o ../OBJ/STK.o

../OBJ/ESTK.o: ../MAIN/SRC/ESTK.C
	$(CC) $(CFLAGS) -c ../MAIN/SRC/ESTK.C -o ../OBJ/ESTK.o

../OBJ/TSTK.o: ../STK/TST/TSTK.c
	$(CC) $(CFLAGS) -c ../STK/TST/TSTK.c -o ../OBJ/TSTK.o

../OBJ/UTST.o: ../STACK/TST/UTST.C
	$(CC) $(CFLAGS) -c ../STK/TST/UTST.C -o ../OBJ/UTST.o
