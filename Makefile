CPPFLAGS=-O3

TARGETS=main size empty segfault strings

empty: empty.o a.o b.o 
	g++ empty.o a.o b.o -o empty

a.o: one.hh
b.o: one.hh

all: $(TARGETS)

.PHONY: clean
clean: 
	rm -f $(TARGETS)
