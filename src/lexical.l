%option noyywrap
%option nounput
%option noinput
%option yylineno

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "syntactical.tab.h"
%}

/* ===================
      TOKENS C-LIKE
   =================== */

/* Palavras-chave */
"function"          { return FUNCTION; }
"struct"            { return STRUCT; }
"return"            { return RETURN; }
"if"                { return IF; }
"else"              { return ELSE; }
"goto"              { return GOTO; }
"asm"               { return ASM; }
"sizeof"            { return ASSIGN_SIZEOF; }

/* Operadores compostos */
"=="                { return ASSIGN_IF_EQUAL; }
"!="                { return ASSIGN_IF_NOT_EQUAL; }
"<="                { return ASSIGN_IF_LESS_OR_EQUAL_THAN; }
">="                { return ASSIGN_IF_MORE_OR_EQUAL_THAN; }
"<"                 { return ASSIGN_IF_LESS_THAN; }
">"                 { return ASSIGN_IF_MORE_THAN; }

"+="                { return ASSIGN_ADD; }
"-="                { return ASSIGN_SUBTRACT; }
"*="                { return ASSIGN_MULTIPLY; }

"="                 { return ASSIGN; }

/* Símbolos */
"{"                 { return BLOCK; }
"}"                 { return END; }
";"                 { return ';'; }
"("                 { return '('; }
")"                 { return ')'; }
","                 { return ','; }

/* Ignorar whitespace */
[ \t\r\n]+          ;

/* Identificadores */
[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.sval = strdup(yytext);
    return ID;
}

/* Números */
[0-9]+ {
    yylval.sval = strdup(yytext);
    return NUMBER;
}

/* Strings C-like */
\"([^\\\"]|\\.)*\" {
    yylval.sval = strdup(yytext);
    return STRING;
}

/* Qualquer outro caractere */
. {
    return yytext[0];
}

%%