#include <stdio.h>
#include <stdlib.h>
#include "src/semantic/ast.h"
#include "src/parser.tab.h"
#include "src/semantic/symbol_table.h"

extern int yyparse();
extern FILE *yyin;
extern ASTNode *root;

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *file = fopen(argv[1], "r");
    if (!file) {
        perror("Could not open file");
        return 1;
    }

    yyin = file;

    // Initialize global symbol table
    init_global_symbol_table();

    // Parse the input file
    int result = yyparse();

    if (result == 0) {

        // Print the AST if successfully parsed
        if (root != NULL) {
            printf("\n--- AST ---\n");
            print_ast(root, 0);
        }
    } else {
        printf("Parsing failed!\n");
    }

    fclose(file);
    return result;
}
