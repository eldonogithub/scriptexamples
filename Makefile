# Query the default goal.
# ifeq ($(.DEFAULT_GOAL),)
#   $(warning no default goal is set)
# endif

# CXX=g++
# CC=gcc
CXXFLAGS=-std=c++11 -O3 -Wall -Wextra -pedantic-errors -Werror
CPPFLAGS=   # e.g. Preprocessor flags
LDLIBS=  # e.g. -llib
LDFLAGS= # e.g. -Lpath

TARGETS=main size segfault strings q31 input empty 

all: $(TARGETS)

empty: empty.o a.o b.o one.o
	g++ $^ -o empty

a.o: one.hh
b.o: one.hh

.PHONY: clean
clean: 
	$(RM) $(TARGETS) *.o
