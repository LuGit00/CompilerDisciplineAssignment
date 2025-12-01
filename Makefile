# Detect OS
UNAME_S := $(shell uname -s)

# Compiler Settings
CC = gcc
CFLAGS = -I. -Isrc -Ibuild

# Assembler Settings
ASM = nasm
LD = ld

# Platform Specific Flags
ifeq ($(UNAME_S),Darwin)
    # macOS (Intel or ARM64 via Rosetta)
    ASM_FLAGS = -f macho64
    LD_FLAGS = -static -platform_version macos 11.0 15.0 -e _start
else
    # Linux
    ASM_FLAGS = -f elf64
    LD_FLAGS = -e _start
endif

# Targets
all: build_dir compiler

build_dir:
	mkdir -p build

# Build the Compiler
compiler: build/lex.yy.c build/parser.tab.c src/semantic/ast.c src/semantic/symbol_table.c src/codegen.c main.c
	$(CC) $(CFLAGS) -o compiler build/lex.yy.c build/parser.tab.c src/semantic/ast.c src/semantic/symbol_table.c src/codegen.c main.c

build/lex.yy.c: src/scanner.l build/parser.tab.h
	flex -o build/lex.yy.c src/scanner.l

build/parser.tab.c build/parser.tab.h: src/parser.y
	bison -d src/parser.y -o build/parser.tab.c
	echo '#include "src/semantic/ast.h"' | cat - build/parser.tab.h > build/parser.tab.h.tmp && mv build/parser.tab.h.tmp build/parser.tab.h
# Build the ABI
build/abi.o: src/abi.asm
	$(ASM) $(ASM_FLAGS) src/abi.asm -o build/abi.o

ifeq ($(UNAME_S),Darwin)
	abi_test: build/abi_macos.o
		$(LD) $(LD_FLAGS) -o build/abi_macos build/abi_macos.o

	build/abi_macos.o: src/abi_macos.asm src/abi.asm
		$(ASM) $(ASM_FLAGS) src/abi_macos.asm -o build/abi_macos.o
endif

# Clean
clean:
	rm -rf build compiler lex.yy.c parser.tab.c parser.tab.h src/*.o src/abi_macos
