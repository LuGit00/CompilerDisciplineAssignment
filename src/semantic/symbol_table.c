#include "symbol_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TABLE_SIZE 100

static SymbolTable *current_scope = NULL;

// Função hash simples
static unsigned int hash(char *name) {
    unsigned int hash_val = 0;
    for (; *name != '\0'; name++) {
        hash_val = *name + (hash_val << 5) - hash_val;
    }
    return hash_val % TABLE_SIZE;
}

// Cria uma nova tabela de símbolos para um novo escopo
static SymbolTable *create_symbol_table(int scope_level, SymbolTable *parent) {
    SymbolTable *new_table = (SymbolTable *)malloc(sizeof(SymbolTable));
    if (!new_table) {
        perror("Failed to allocate SymbolTable");
        exit(EXIT_FAILURE);
    }
    for (int i = 0; i < TABLE_SIZE; i++) {
        new_table->entries[i] = NULL;
    }
    new_table->scope_level = scope_level;
    new_table->parent = parent;
    return new_table;
}

// Inicializa a tabela de símbolos global
void init_global_symbol_table() {
    current_scope = create_symbol_table(0, NULL);
}

// Entra em um novo escopo
void enter_scope() {
    current_scope = create_symbol_table(current_scope->scope_level + 1, current_scope);
    printf("Entrou no escopo: %d\n", current_scope->scope_level);
}

// Sai do escopo atual
void exit_scope() {
    if (current_scope == NULL) {
        fprintf(stderr, "Erro: Tentativa de sair de um escopo nulo.\n");
        exit(EXIT_FAILURE);
    }
    SymbolTable *parent_scope = current_scope->parent;
    // Liberar memória da tabela de símbolos atual (simplificado, sem liberar símbolos individuais)
    free(current_scope);
    current_scope = parent_scope;
    printf("Saiu do escopo: %d\n", current_scope ? current_scope->scope_level : -1);
}

// Adiciona um símbolo ao escopo atual
void add_symbol(char *name, SymbolType type) {
    if (current_scope == NULL) {
        fprintf(stderr, "Erro: Nenhuma tabela de símbolos ativa para adicionar símbolo.\n");
        exit(EXIT_FAILURE);
    }

    unsigned int index = hash(name);
    SymbolTableEntry *new_entry = (SymbolTableEntry *)malloc(sizeof(SymbolTableEntry));
    if (!new_entry) {
        perror("Failed to allocate SymbolTableEntry");
        exit(EXIT_FAILURE);
    }

    Symbol *new_symbol = (Symbol *)malloc(sizeof(Symbol));
    if (!new_symbol) {
        perror("Failed to allocate Symbol");
        exit(EXIT_FAILURE);
    }
    new_symbol->name = strdup(name);
    new_symbol->type = type;
    new_symbol->scope_level = current_scope->scope_level;

    new_entry->symbol = new_symbol;
    new_entry->next = current_scope->entries[index];
    current_scope->entries[index] = new_entry;

    printf("Símbolo adicionado no escopo %d: %s (Tipo: %d)\n", current_scope->scope_level, name, type);
}

// Procura um símbolo no escopo atual
Symbol *lookup_symbol_in_current_scope(char *name) {
    if (current_scope == NULL) return NULL;

    unsigned int index = hash(name);
    SymbolTableEntry *entry = current_scope->entries[index];
    while (entry != NULL) {
        if (strcmp(entry->symbol->name, name) == 0) {
            return entry->symbol;
        }
        entry = entry->next;
    }
    return NULL;
}

// Procura um símbolo em todos os escopos (do atual ao global)
Symbol *lookup_symbol(char *name) {
    SymbolTable *temp_scope = current_scope;
    while (temp_scope != NULL) {
        unsigned int index = hash(name);
        SymbolTableEntry *entry = temp_scope->entries[index];
        while (entry != NULL) {
            if (strcmp(entry->symbol->name, name) == 0) {
                return entry->symbol;
            }
            entry = entry->next;
        }
        temp_scope = temp_scope->parent;
    }
    return NULL;
}

// Imprime a pilha de tabelas de símbolos (para depuração)
void print_symbol_table_stack() {
    SymbolTable *temp_scope = current_scope;
    printf("\n--- Pilha de Tabelas de Símbolos ---\n");
    while (temp_scope != NULL) {
        printf("Escopo %d:\n", temp_scope->scope_level);
        for (int i = 0; i < TABLE_SIZE; i++) {
            SymbolTableEntry *entry = temp_scope->entries[i];
            while (entry != NULL) {
                printf("  [%d]: %s (Tipo: %d)\n", i, entry->symbol->name, entry->symbol->type);
                entry = entry->next;
            }
        }
        temp_scope = temp_scope->parent;
    }
    printf("------------------------------------\n");
}