#include "parser.tab.h"
#include "src/codegen.h"
#include "src/semantic/ast.h"
#include "src/semantic/symbol_table.h"
#include <stdio.h>
#include <stdlib.h>

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
  init_global_symbol_table();

  int result = yyparse();

  if (result == 0 && root != NULL) {
    printf("\n--- AST ---\n");
    print_ast(root, 0);

    char output_filename[256];
    snprintf(output_filename, sizeof(output_filename), "%s.asm", argv[1]);

    FILE *output_file = fopen(output_filename, "w");
    if (!output_file) {
      perror("Could not open output file");
      return 1;
    }

    printf("\n--- Generating Assembly ---\n");
    generate_code(root, output_file);
    fclose(output_file);
    printf("Assembly written to: %s\n", output_filename);
  } else {
    printf("Parsing failed!\n");
  }

  fclose(file);
  return result;
}
