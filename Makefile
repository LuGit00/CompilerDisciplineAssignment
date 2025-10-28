CC      = gcc
FLEX    = flex
BISON   = bison
CFLAGS  = -Wall -Wextra -g -Iparser -Isemantic -Iir_generator
LDFLAGS =

# Diretórios
LEXER_DIR   = lexer
PARSER_DIR  = parser
SEMANTIC_DIR= semantic
IR_DIR      = ir_generator

TARGET = compiler

# Gerados por Bison/Flex
GEN_C = $(PARSER_DIR)/parser.tab.c $(LEXER_DIR)/lex.yy.c
GEN_H = $(PARSER_DIR)/parser.tab.h

# Objetos
OBJS = \
  $(PARSER_DIR)/parser.tab.o \
  $(LEXER_DIR)/lex.yy.o \
  $(SEMANTIC_DIR)/ast.o \
  $(SEMANTIC_DIR)/symbol_table.o \
  $(IR_DIR)/tac.o \
  main.o

all: $(TARGET)

$(PARSER_DIR)/parser.tab.c $(PARSER_DIR)/parser.tab.h: $(PARSER_DIR)/parser.y
	$(BISON) -d -v -o $(PARSER_DIR)/parser.tab.c $(PARSER_DIR)/parser.y

$(LEXER_DIR)/lex.yy.c: $(LEXER_DIR)/scanner.l $(PARSER_DIR)/parser.tab.h
	$(FLEX) -o $(LEXER_DIR)/lex.yy.c $(LEXER_DIR)/scanner.l

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS)

.PHONY: clean test
clean:
	rm -f $(TARGET) $(OBJS) $(GEN_C) $(GEN_H) *.output

# Roda o compilador nos exemplos
test: all
	@./$(TARGET) ../tests/examples/valid_program.c || true
	@./$(TARGET) ../tests/examples/syntax_error.c || true