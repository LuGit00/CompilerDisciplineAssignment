#include <stdio.h>
#include <stdlib.h>
#include "semantic/ast.h"
#include "semantic/symbol_table.h"
#include "ir_generator/tac.h"
#include "parser.tab.h"

extern FILE *yyin;
extern ASTNode *root;
extern int yyparse(void);

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) {
            perror("Não foi possível abrir o arquivo de entrada");
            return 1;
        }
        yyin = f;
    } else {
        printf("Uso: %s <arquivo_entrada>\n", argv[0]);
        return 1;
    }

    init_global_symbol_table(); // Inicializa a tabela de símbolos global

    printf("Iniciando análise léxica e sintática...\n");
    yyparse();

    if (root) {
        printf("Análise concluída com sucesso. Árvore Sintática Abstrata (AST):\n");
        print_ast(root, 0);

        printf("\nGerando Código de Três Endereços (TAC):\n");
        TAC *tac_code = generate_tac(root);
        print_tac(tac_code);

    } else {
        printf("Análise concluída, mas nenhuma AST foi gerada (possíveis erros de sintaxe).\n");
    }

    print_symbol_table_stack(); // Imprime a tabela de símbolos para depuração

    if (yyin != NULL && yyin != stdin) {
        fclose(yyin);
    }

    return 0;
}