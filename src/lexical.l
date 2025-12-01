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

%%

array                         { return ARRAY; }
struct                        { return STRUCT; }
private                       { return PRIVATE; }
protected                     { return PROTECTED; }
public                        { return PUBLIC; }
function                      { return FUNCTION; }
execute                       { return EXECUTE; }
return                        { return RETURN; }
label                         { return LABEL; }
goto                          { return GOTO; }
block                         { return BLOCK; }
if                            { return IF; }
elif                          { return ELIF; }
else                          { return ELSE; }
"=" { return ASSIGN; }
"+=" { return ASSIGN_ADD; }
"-=" { return ASSIGN_SUBTRACT; }
"*=" { return ASSIGN_MULTIPLY; }
"<?" { return ASSIGN_IF_LESS_THAN; }
">?" { return ASSIGN_IF_MORE_THAN; }
"<=?" { return ASSIGN_IF_LESS_OR_EQUAL_THAN; }
">=?" { return ASSIGN_IF_MORE_OR_EQUAL_THAN; }
"==?" { return ASSIGN_IF_EQUAL; }
"!=?" { return ASSIGN_IF_NOT_EQUAL; }
asm                           { return ASM; }
assign_sizeof                 { return ASSIGN_SIZEOF; }
end                           { return END; }

[ \t\r\n]+                    ;   /* skip whitespace */

[a-zA-Z_][a-zA-Z0-9_]*        { yylval.sval = strdup(yytext); return ID; }
[0-9]+                        { yylval.sval = strdup(yytext); return NUMBER; }
\"([^\\\"]|\\.)*\"            { yylval.sval = strdup(yytext); return STRING; }

.                             { return yytext[0]; }

%%