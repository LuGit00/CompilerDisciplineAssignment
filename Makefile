CC     = gcc
FLEX   = flex
BISON  = bison
CFLAGS = -Wall -Wextra -g -Isrc
TARGET = compiler

all:
	$(BISON) -d -o src/syntactical.tab.c src/syntactical.y
	$(FLEX) -o src/lexical.yy.c src/lexical.l
	$(CC) $(CFLAGS) -c src/syntactical.tab.c -o src/syntactical.tab.o
	$(CC) $(CFLAGS) -c src/lexical.yy.c -o src/lexical.yy.o
	$(CC) -o $(TARGET) src/syntactical.tab.o src/lexical.yy.o

clean:
	rm -f $(TARGET) src/syntactical.tab.c src/syntactical.tab.h src/lexical.yy.c src/syntactical.tab.o src/lexical.yy.o src/parser.output src/parser.tab.c src/parser.tab.h
