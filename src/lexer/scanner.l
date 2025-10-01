%{
#include <stdio.h>
#include <string.h>
#include "../semantic/ast.h" // Inclui a definição de ASTNode
#include "../parser/parser.tab.h" // Inclui os tokens e a união yylval

// Declaração externa para yylval
extern YYSTYPE yylval;
%}

%%
"int"       { return INT; }
"float"     { return FLOAT; }
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"return"    { return RETURN; }
"print"     { return PRINT; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return ID; }
[0-9]+\.?[0-9]*([Ee][+-]?[0-9]+)? { yylval.sval = strdup(yytext); return NUMBER; }

"="         { return ASSIGN; }
"+"         { return ADD; }
"-"         { return SUB; }
"*"         { return MUL; }
"/"         { return DIV; }
"=="        { return EQ; }
"!="        { return NE; }
"<"         { return LT; }
">"         { return GT; }
"<="        { return LE; }
">="        { return GE; }

"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
";"         { return SEMICOLON; }

[ \t\n]+    { /* Ignorar espaços em branco */ }
"//".*      { /* Ignorar comentários de linha única */ }
"/*"([^*]|\*+[^*/])*\*+"/" { /* Ignorar comentários de múltiplas linhas */ }

.           { printf("Erro léxico: Caractere inválido '%c'\n", yytext[0]); }
%%

int yywrap() {
    return 1;
}