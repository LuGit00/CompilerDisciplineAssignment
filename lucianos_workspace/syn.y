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

<integer> ::= digit ( empty | <integer> )
<identifier> ::= ( lower | upper | '_' | '.' ) ( empty | <identifier> )
<string_chars> ::= ( empty | '\' ''' | '\' '"' | any_except_quotes ) ( empty | <string_chars> )
<string> ::= '"' <string_chars> '"'

::= <identifier> | <string> | <integer>

<variable_definition_parameters> ::= <identifier> ( empty | ',' <variable_definition_parameters> )
<variable_definition> ::= ( empty | 'static' ) 'var' <integer> ',' <variable_definition_parameters>
<definition> ::= <variable_definition> | <structure_definition> | <function_definition>
<program> ::= <definition> ( empty | <program> )

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