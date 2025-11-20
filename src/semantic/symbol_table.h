#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdbool.h>

typedef enum {
    SYM_INT,
    SYM_FLOAT,
    SYM_UNKNOWN,
    SYM_FUNCTION
} SymbolType;

typedef struct Symbol {
    char *name;
    SymbolType type;
    int scope_level;
    // Adicionar mais atributos conforme necessário, como lista de parâmetros para funções
    // struct ParamList *params;
} Symbol;

typedef struct SymbolTableEntry {
    Symbol *symbol;
    struct SymbolTableEntry *next;
} SymbolTableEntry;

typedef struct SymbolTable {
    SymbolTableEntry *entries[100]; // Tabela hash simples
    int scope_level;
    struct SymbolTable *parent;
} SymbolTable;

// Funções para manipulação da tabela de símbolos
void init_global_symbol_table();
void enter_scope();
void exit_scope();
void add_symbol(char *name, SymbolType type);
Symbol *lookup_symbol(char *name);
Symbol *lookup_symbol_in_current_scope(char *name);
void print_symbol_table_stack();

#endif // SYMBOL_TABLE_H