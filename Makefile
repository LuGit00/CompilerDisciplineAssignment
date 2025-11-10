CC      = gcc
FLEX    = flex
BISON   = bison
CFLAGS  = -Wall -Wextra -g -Isrc -Isrc/parser -Isrc/semantic -Isrc/ir_generator
LDFLAGS =

TARGET = compiler

# Gerados por Bison/Flex
GEN_C = src/parser.tab.c src/lex.yy.c
GEN_H = src/parser.tab.h

# Objetos
OBJS = \
  src/parser.tab.o \
  src/lex.yy.o \
  src/semantic/ast.o \
  src/semantic/symbol_table.o \
  main.o

all: $(TARGET)

src/parser.tab.c src/parser.tab.h: src/parser.y
	$(BISON) -d -v -o src/parser.tab.c src/parser.y

src/lex.yy.c: src/scanner.l src/parser.tab.h
	$(FLEX) -o src/lex.yy.c src/scanner.l

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

src/parser.tab.o: src/parser.tab.c
	$(CC) $(CFLAGS) -c $< -o $@

src/lex.yy.o: src/lex.yy.c
	$(CC) $(CFLAGS) -c $< -o $@

src/semantic/ast.o: src/semantic/ast.c
	$(CC) $(CFLAGS) -c $< -o $@

src/semantic/symbol_table.o: src/semantic/symbol_table.c
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS)

.PHONY: clean test
clean:
	rm -f $(TARGET) $(OBJS) $(GEN_C) $(GEN_H) *.output src/parser.tab.c src/parser.tab.h src/lex.yy.c src/parser.tab.output

# Roda o compilador nos exemplos
test: all
	@./$(TARGET) tests/examples/valid_program.c || true
	@./$(TARGET) tests/examples/syntax_error.c || true