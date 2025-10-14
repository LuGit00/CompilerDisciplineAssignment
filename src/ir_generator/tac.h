#ifndef TAC_H
#define TAC_H

#include "../semantic/ast.h"

typedef enum {
    TAC_ADD,
    TAC_SUB,
    TAC_MUL,
    TAC_DIV,
    TAC_ASSIGN,
    TAC_IF_EQ,
    TAC_IF_NE,
    TAC_IF_LT,
    TAC_IF_GT,
    TAC_IF_LE,
    TAC_IF_GE,
    TAC_GOTO,
    TAC_LABEL,
    TAC_RETURN,
    TAC_CALL,
    TAC_PARAM,
    TAC_VAR_DECL,
    TAC_PRINT
} TACOp;

typedef struct TAC {
    TACOp op;
    char *arg1;
    char *arg2;
    char *result;
    struct TAC *next;
} TAC;

TAC *create_tac(TACOp op, char *arg1, char *arg2, char *result);
void print_tac(TAC *tac);
TAC *generate_tac(ASTNode *node);

#endif // TAC_H