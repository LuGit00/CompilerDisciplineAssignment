#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

ASTNode *create_node(ASTNodeType type, ASTNode *left, ASTNode *right, ASTNode *middle, ASTNode *next) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) {
        perror("Failed to allocate ASTNode");
        exit(EXIT_FAILURE);
    }
    node->type = type;
    node->left = left;
    node->right = right;
    node->middle = middle;
    node->next = next;
    node->value = NULL;
    node->result = NULL; // Inicializa o campo result
    return node;
}

ASTNode *create_leaf(ASTNodeType type, char *value) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) {
        perror("Failed to allocate ASTNode");
        exit(EXIT_FAILURE);
    }
    node->type = type;
    node->left = NULL;
    node->right = NULL;
    node->middle = NULL;
    node->next = NULL;
    if (value) {
        node->value = strdup(value);
        if (!node->value) {
            perror("Failed to duplicate string");
            exit(EXIT_FAILURE);
        }
    } else {
        node->value = NULL;
    }
    node->result = NULL; // Inicializa o campo result
    return node;
}

void print_ast(ASTNode *node, int indent) {
    if (!node) return;

    for (int i = 0; i < indent; i++) {
        printf("  ");
    }

    switch (node->type) {
        case NODE_PROGRAM: printf("PROGRAM\n"); break;
        case NODE_FUNCTION_DEFINITION: printf("FUNCTION_DEFINITION\n"); break;
        case NODE_STATEMENT_LIST: printf("STATEMENT_LIST\n"); break;
        case NODE_DECLARATION: printf("DECLARATION\n"); break;
        case NODE_ASSIGNMENT: printf("ASSIGNMENT\n"); break;
        case NODE_IF: printf("IF\n"); break;
        case NODE_IF_ELSE: printf("IF_ELSE\n"); break;
        case NODE_WHILE: printf("WHILE\n"); break;
        case NODE_RETURN: printf("RETURN\n"); break;
        case NODE_ADD: printf("ADD\n"); break;
        case NODE_SUB: printf("SUB\n"); break;
        case NODE_MUL: printf("MUL\n"); break;
        case NODE_DIV: printf("DIV\n"); break;
        case NODE_EQ: printf("EQUAL\n"); break;
        case NODE_NE: printf("NOT_EQUAL\n"); break;
        case NODE_LT: printf("LESS_THAN\n"); break;
        case NODE_GT: printf("GREATER_THAN\n"); break;
        case NODE_LE: printf("LESS_EQUAL\n"); break;
        case NODE_GE: printf("GREATER_EQUAL\n"); break;
        case NODE_ID: printf("ID: %s\n", node->value); break;
        case NODE_NUMBER: printf("NUMBER: %s\n", node->value); break;
        case NODE_TYPE_INT: printf("TYPE: INT\n"); break;
        case NODE_TYPE_FLOAT: printf("TYPE: FLOAT\n"); break;
        case NODE_BLOCK: printf("BLOCK\n"); break;
        default: printf("UNKNOWN_NODE_TYPE\n"); break;
    }

    print_ast(node->left, indent + 1);
    print_ast(node->middle, indent + 1);
    print_ast(node->right, indent + 1);
    print_ast(node->next, indent);
}