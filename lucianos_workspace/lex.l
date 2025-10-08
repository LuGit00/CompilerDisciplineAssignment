%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "syn.tab.h"
%}
%option noyywrap
%option yylineno
%%
include { return INCLUDE; }
namespace { return NAMESPACE; }
public { return PUBLIC; }
protected { return PROTECTED; }
private { return PRIVATE; }
function { return FUNCTION; }
return { return RETURN; }
label { return LABEL; }
goto { return GOTO; }
block { return BLOCK; }
immediate { return IMMEDIATE; }
var { return VAR; }
struct { return STRUCT; }
assign { return ASSIGN; }
add { return ADD; }
subtract { return SUBTRACT; }
multiply { return MULTIPLY; }
divide { return DIVIDE; }
if_less_than { return IF_LESS_THAN; }
if_more_than { return IF_MORE_THAN; }
if_less_or_equal_than { return IF_LESS_OR_EQUAL_THAN; }
if_more_or_equal_than { return IF_MORE_OR_EQUAL_THAN; }
if_equals { return IF_EQUALS; }
if_not_equals { return IF_NOT_EQUALS; }
if { return IF; }
then { return THEN; }
elif { return ELIF; }
else { return ELSE; }
while { return WHILE; }
do { return DO; }
end { return END; }
asm { return ASM; }
\'([^\'\\]|\\.)*\' { yylval.sval=strdup(yytext); return STRING; }
\"([^\"\\]|\\.)*\" { yylval.sval=strdup(yytext); return STRING; }
[0-9]+ { yylval.ival=strtoll(yytext,NULL,10); return INTEGER; }
[A-Za-z._:/\\][0-9A-Za-z._:/\\-]* { yylval.sval=strdup(yytext); return IDENTIFIER; }
, { return SEPARATOR; }
. ;
%% 
