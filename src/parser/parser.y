%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../semantic/ast.h"
#include "../semantic/symbol_table.h"

extern int yylex();
extern void yyerror(const char *s);

ASTNode *root = NULL;

// Função auxiliar para verificar tipos
SymbolType get_expression_type(ASTNode *node) {
    if (!node) return SYM_UNKNOWN;
    switch (node->type) {
        case NODE_ID: {
            Symbol *sym = lookup_symbol(node->value);
            if (sym) return sym->type;
            fprintf(stderr, "Erro semântico: Variável ‘%s’ não declarada.\n", node->value);
            return SYM_UNKNOWN;
        }
        case NODE_NUMBER: // Simplificado: assume que todos os números são INT por enquanto
            return SYM_INT;
        case NODE_ADD:
        case NODE_SUB:
        case NODE_MUL:
        case NODE_DIV: {
            SymbolType left_type = get_expression_type(node->left);
            SymbolType right_type = get_expression_type(node->right);
            if (left_type == SYM_UNKNOWN || right_type == SYM_UNKNOWN) return SYM_UNKNOWN;
            if (left_type == SYM_FLOAT || right_type == SYM_FLOAT) return SYM_FLOAT;
            return SYM_INT;
        }
        default: return SYM_UNKNOWN;
    }
}

// Função auxiliar para verificar compatibilidade de tipos em atribuições
void check_assignment_type(ASTNode *id_node, ASTNode *expr_node) {
    Symbol *id_sym = lookup_symbol(id_node->value);
    if (!id_sym) {
        fprintf(stderr, "Erro semântico: Variável ‘%s’ não declarada na atribuição.\n", id_node->value);
        return;
    }
    SymbolType expr_type = get_expression_type(expr_node);
    if (expr_type == SYM_UNKNOWN) return;

    if (id_sym->type == SYM_INT && expr_type == SYM_FLOAT) {
        fprintf(stderr, "Aviso semântico: Atribuição de float para int (perda de precisão) na variável ‘%s’.\n", id_sym->name);
    } else if (id_sym->type == SYM_FLOAT && expr_type == SYM_INT) {
        // Coerção implícita de int para float é geralmente aceitável
    } else if (id_sym->type != expr_type) {
        fprintf(stderr, "Erro semântico: Tipos incompatíveis na atribuição para ‘%s’.\n", id_sym->name);
    }
}

%}

%union {
    int ival;
    float fval;
    char *sval;
    ASTNode *node;
}

%token <sval> ID
%token <sval> NUMBER
%token INT FLOAT IF ELSE WHILE RETURN PRINT
%token ASSIGN ADD SUB MUL DIV EQ NE LT GT LE GE
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON

%type <node> program function_definition_list function_definition statement_list statement declaration expression assignment_statement while_statement return_statement print_statement
%type <node> term factor relational_expression block
%type <node> matched_statement unmatched_statement

%start program

%nonassoc IFX
%nonassoc ELSE

%%

program:
    function_definition_list { root = $1; }
    ;

function_definition_list:
    function_definition_list function_definition { $$ = create_node(NODE_PROGRAM, $1, $2, NULL, NULL); }
    | function_definition { $$ = $1; }
    ;

function_definition:
    INT ID LPAREN RPAREN LBRACE { enter_scope(); add_symbol($2, SYM_FUNCTION); } statement_list RBRACE { exit_scope(); $$ = create_node(NODE_FUNCTION_DEFINITION, create_leaf(NODE_TYPE_INT, NULL), create_leaf(NODE_ID, $2), $7, NULL); free($2); }
    ;

statement_list:
    statement_list statement { $$ = create_node(NODE_STATEMENT_LIST, $1, $2, NULL, NULL); }
    | { $$ = NULL; } // Lista de statements pode ser vazia
    ;

statement:
    matched_statement
    | unmatched_statement
    ;

matched_statement:
    declaration SEMICOLON { $$ = $1; }
    | assignment_statement SEMICOLON { $$ = $1; }
    | return_statement SEMICOLON { $$ = $1; }
    | print_statement SEMICOLON { $$ = $1; }
    | while_statement
    | IF LPAREN relational_expression RPAREN matched_statement ELSE matched_statement { $$ = create_node(NODE_IF_ELSE, $3, $5, $7, NULL); }
    | block { $$ = $1; }

unmatched_statement:
    IF LPAREN relational_expression RPAREN statement
    | IF LPAREN relational_expression RPAREN matched_statement ELSE unmatched_statement
    ;

block:
    LBRACE { enter_scope(); } statement_list RBRACE { exit_scope(); $$ = $3; }
    ;

declaration:
    INT ID { add_symbol($2, SYM_INT); $$ = create_node(NODE_DECLARATION, create_leaf(NODE_TYPE_INT, NULL), create_leaf(NODE_ID, $2), NULL, NULL); free($2); }
    | FLOAT ID { add_symbol($2, SYM_FLOAT); $$ = create_node(NODE_DECLARATION, create_leaf(NODE_TYPE_FLOAT, NULL), create_leaf(NODE_ID, $2), NULL, NULL); free($2); }
    ;

assignment_statement:
    ID ASSIGN expression { check_assignment_type(create_leaf(NODE_ID, $1), $3); $$ = create_node(NODE_ASSIGNMENT, create_leaf(NODE_ID, $1), $3, NULL, NULL); free($1); }
    ;

expression:
    expression ADD term { $$ = create_node(NODE_ADD, $1, $3, NULL, NULL); }
    | expression SUB term { $$ = create_node(NODE_SUB, $1, $3, NULL, NULL); }
    | term { $$ = $1; }
    ;

term:
    term MUL factor { $$ = create_node(NODE_MUL, $1, $3, NULL, NULL); }
    | term DIV factor { $$ = create_node(NODE_DIV, $1, $3, NULL, NULL); }
    | factor { $$ = $1; }
    ;

factor:
    NUMBER { $$ = create_leaf(NODE_NUMBER, $1); free($1); }
    | ID { 
        Symbol *sym = lookup_symbol($1);
        if (!sym) {
            fprintf(stderr, "Erro semântico: Variável ‘%s’ não declarada.\n", $1);
        }
        $$ = create_leaf(NODE_ID, $1); free($1); 
    }
    | LPAREN expression RPAREN { $$ = $2; }
    ;

relational_expression:
    expression EQ expression { $$ = create_node(NODE_EQ, $1, $3, NULL, NULL); }
    | expression NE expression { $$ = create_node(NODE_NE, $1, $3, NULL, NULL); }
    | expression LT expression { $$ = create_node(NODE_LT, $1, $3, NULL, NULL); }
    | expression GT expression { $$ = create_node(NODE_GT, $1, $3, NULL, NULL); }
    | expression LE expression { $$ = create_node(NODE_LE, $1, $3, NULL, NULL); }
    | expression GE expression { $$ = create_node(NODE_GE, $1, $3, NULL, NULL); }
    ;

while_statement:
    WHILE LPAREN relational_expression RPAREN block { $$ = create_node(NODE_WHILE, $3, $5, NULL, NULL); }
    ;

return_statement:
    RETURN expression { $$ = create_node(NODE_RETURN, $2, NULL, NULL, NULL); }
    ;

print_statement:
    PRINT LPAREN expression RPAREN { $$ = create_node(NODE_PRINT, $3, NULL, NULL, NULL); }
    | PRINT LPAREN ID RPAREN { $$ = create_node(NODE_PRINT, create_leaf(NODE_ID, $3), NULL, NULL, NULL); free($3); }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
}