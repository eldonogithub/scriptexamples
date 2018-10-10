CPPFLAGS=-O3

TARGETS=main size empty segfault strings q31
TARGETS=q31

all: $(TARGETS)

empty: empty.o a.o b.o 
	g++ empty.o a.o b.o -o empty

a.o: one.hh
b.o: one.hh

.PHONY: clean
clean: 
	rm -f $(TARGETS)
