%{
#include <stdio.h>
#include <string.h>
#include "syn.tab.h"
%}

%option noyywrap

%%
var[ \t]+ { return VAR; }
[0-9a-zA-Z.:-_]* { yylval.sval = strdup(yytext); return IDENTIFIER; }
. ;
%%