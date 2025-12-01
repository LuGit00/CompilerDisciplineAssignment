#ifndef CODEGEN_H
#define CODEGEN_H

#include "semantic/ast.h"
#include <stdio.h>

// Main code generation entry point
void generate_code(ASTNode *root, FILE *output);

#endif // CODEGEN_H
