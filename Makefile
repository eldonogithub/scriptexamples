CPPFLAGS=-O3

empty: empty.o a.o b.o 
	g++ empty.o a.o b.o -o empty

a.o: one.hh
b.o: one.hh

all: main size empty segfault strings
