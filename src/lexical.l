%{
#include <stdio.h>
#include <string.h>
#include "semantic/ast.h"
#include "parser.tab.h"

extern YYSTYPE yylval;
%}

%%

array { return ARRAY; }
struct { return STRUCT; }
private { return PRIVATE; }
protected { return PROTECTED; }
public { return PUBLIC; }
function { return FUNCTION; }
execute { return EXECUTE; }
return { return RETURN; }
label { return LABEL; }
goto { return GOTO; }
block { return BLOCK; }
if { return IF; }
elif { return ELIF; }
else { return ELSE; }
assign { return ASSIGN; }
assign_add { return ASSIGN_ADD; }
assign_subtract { return ASSIGN_SUBTRACT; }
assign_multiply { return ASSIGN_MULTIPLY; }
assign_if_less_than { return ASSIGN_IF_LESS_THAN; }
assign_if_more_than { return ASSIGN_IF_MORE_THAN; }
assign_if_less_or_equal_than { return ASSIGN_IF_LESS_OR_EQUAL_THAN; }
assign_if_more_or_equal_than { return ASSIGN_IF_MORE_OR_EQUAL_THAN; }
assign_if_equal { return ASSIGN_IF_EQUAL; }
assign_if_not_equal { return ASSIGN_IF_NOT_EQUAL; }
asm { return ASM; }
assign_sizeof { return ASSIGN_SIZEOF; }
end { return END; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return IDENTIFIER; }
[1-9][0-9]* { yylval.sval = strdup(yytext); return NUMBER; }
".*" { yylval.sval = strdup(yytext); return STRING; }
. ;

%%

int yywrap(void)
{
    return 1;
}