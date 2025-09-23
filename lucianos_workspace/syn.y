%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror(const char *s);
%}

%union {
	char *sval;
}

%token <sval> IDENTIFIER
%token VAR

%start program

%%

global_statement:
	VAR IDENTIFIER { printf("Parsed a declaration for variable: %s\n", $2); free($2); }
	;

global_statements:
	global_statement
	| global_statement global_statements
	;

program: 
	global_statements
	;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

int main(void)
{
	printf("Enter a variable declaration (e.g., var my_var ;)...\n");
	yyparse();
	return 0;
}