#ifndef AST_H
#define AST_H

typedef enum {
    NODE_PROGRAM,
    NODE_FUNCTION_DEFINITION,
    NODE_STATEMENT_LIST,
    NODE_DECLARATION,
    NODE_ASSIGNMENT,
    NODE_IF,
    NODE_IF_ELSE,
    NODE_WHILE,
    NODE_RETURN,
    NODE_ADD,
    NODE_SUB,
    NODE_MUL,
    NODE_DIV,
    NODE_EQ,
    NODE_NE,
    NODE_LT,
    NODE_GT,
    NODE_LE,
    NODE_GE,
    NODE_ID,
    NODE_NUMBER,
    NODE_TYPE_INT,
    NODE_TYPE_FLOAT,
    NODE_BLOCK // Adicionado
} ASTNodeType;

typedef struct ASTNode {
    ASTNodeType type;
    struct ASTNode *left;
    struct ASTNode *right;
    struct ASTNode *middle;
    struct ASTNode *next;
    char *value;
    char *result; // Adicionado para armazenar o resultado da expressão em TAC
} ASTNode;

ASTNode *create_node(ASTNodeType type, ASTNode *left, ASTNode *right, ASTNode *middle, ASTNode *next);
ASTNode *create_leaf(ASTNodeType type, char *value);
void print_ast(ASTNode *node, int indent);

#endif // AST_H