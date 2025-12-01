%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern void yyerror(const char *s);
extern FILE *yyin;
extern int yylineno;
extern char *yytext;

FILE *out_file = NULL;
%}

%define parse.error verbose
%define parse.lac full

%union {
    char *sval;
}

/* ============
      TOKENS
   ============ */
%token STRUCT FUNCTION RETURN IF ELSE GOTO ASM
%token ASSIGN ASSIGN_ADD ASSIGN_SUBTRACT ASSIGN_MULTIPLY
%token ASSIGN_IF_LESS_THAN ASSIGN_IF_MORE_THAN
%token ASSIGN_IF_LESS_OR_EQUAL_THAN ASSIGN_IF_MORE_OR_EQUAL_THAN
%token ASSIGN_IF_EQUAL ASSIGN_IF_NOT_EQUAL
%token ASSIGN_SIZEOF
%token BLOCK END
%token <sval> ID NUMBER STRING

%type <sval> num_str_id

/* Precedência */
%right '='
%left ASSIGN_ADD ASSIGN_SUBTRACT ASSIGN_MULTIPLY
%left ASSIGN_IF_EQUAL ASSIGN_IF_NOT_EQUAL
%left ASSIGN_IF_LESS_THAN ASSIGN_IF_MORE_THAN
%left ASSIGN_IF_LESS_OR_EQUAL_THAN ASSIGN_IF_MORE_OR_EQUAL_THAN

%start global_scope

%%

/* ======================
      Tipos auxiliares
   ====================== */

num_str_id :
      NUMBER
    | STRING
    | ID
    ;

/* ====================================
      Declaração de funções estilo C
   ==================================== */

function_declaration :
    FUNCTION ID '(' ')' BLOCK
        { fprintf(out_file,"function %s\n",$2); }
    function_body
    END
        { fprintf(out_file,"end\n"); }
    ;

/* ===============================
      Corpo de funções / blocos
   =============================== */

function_body :
        /* vazio */
    | function_body stmt
    ;

/* ====================================
      Declaração de structs estilo C
   ==================================== */

struct_declaration :
    STRUCT ID BLOCK
        { fprintf(out_file,"struct %s\n",$2); }
    struct_body
    END ';'
        { fprintf(out_file,"end\n"); }
    ;

struct_body :
        /* vazio */
    | struct_body stmt
    ;

/* ============================
      Declarações e comandos
   ============================ */

stmt :
      /* atribuições estilo C */
      ID ASSIGN num_str_id ';'
        { fprintf(out_file,"assign %s, %s\n",$1,$3); }

    | ID ASSIGN_ADD num_str_id ';'
        { fprintf(out_file,"assign_add %s, %s, %s\n",$1,$1,$3); }

    | ID ASSIGN_SUBTRACT num_str_id ';'
        { fprintf(out_file,"assign_subtract %s, %s, %s\n",$1,$1,$3); }

    | ID ASSIGN_MULTIPLY num_str_id ';'
        { fprintf(out_file,"assign_multiply %s, %s, %s\n",$1,$1,$3); }

    | ID ASSIGN_IF_LESS_THAN num_str_id ';'
        { fprintf(out_file,"assign_if_less_than %s, %s, %s\n",$1,$1,$3); }

    | ID ASSIGN_IF_MORE_THAN num_str_id ';'
        { fprintf(out_file,"assign_if_more_than %s, %s, %s\n",$1,$1,$3); }

    | ID ASSIGN_IF_LESS_OR_EQUAL_THAN num_str_id ';'
        { fprintf(out_file,"assign_if_less_or_equal_than %s, %s, %s\n",$1,$1,$3); }

    | ID ASSIGN_IF_MORE_OR_EQUAL_THAN num_str_id ';'
        { fprintf(out_file,"assign_if_more_or_equal_than %s, %s, %s\n",$1,$1,$3); }

    | ID ASSIGN_IF_EQUAL num_str_id ';'
        { fprintf(out_file,"assign_if_equal %s, %s, %s\n",$1,$1,$3); }

    | ID ASSIGN_IF_NOT_EQUAL num_str_id ';'
        { fprintf(out_file,"assign_if_not_equal %s, %s, %s\n",$1,$1,$3); }

    /* sizeof */
    | ID ASSIGN_SIZEOF ID ';'
        { fprintf(out_file,"assign_sizeof %s, %s\n",$1,$3); }

    /* IF / ELSE estilo C */
    | IF '(' num_str_id ')' BLOCK
        { fprintf(out_file,"if %s\n",$3); }
      function_body
      END
        { /* nada extra */ }

    | ELSE BLOCK
        { fprintf(out_file,"else\n"); }
      function_body
      END
        { /* nada extra */ }

    /* goto */
    | GOTO ID ';'
        { fprintf(out_file,"goto %s\n",$2); }

    /* return */
    | RETURN ';'
        { fprintf(out_file,"return\n"); }

    /* asm literal */
    | ASM STRING ';'
        { fprintf(out_file,"asm %s\n",$2); }

    ;

/* ===================
      Escopo global
   ===================*/

global_scope :
        /* vazio */
    | global_scope stmt
    ;

%%

/* ========================
      Tratamento de erro
   ======================== */
void yyerror(const char *s)
{
    if (yytext && yytext[0] != '\0')
        fprintf(stderr,
                "Parser error at line %d near '%s': %s\n",
                yylineno, yytext, s);
    else
        fprintf(stderr,
                "Parser error at line %d at end of input: %s\n",
                yylineno, s);
}

/* ==========
      main
   ========== */

int yyparse(void);

int main(int argc,char **argv)
{
    const char *input_name = NULL;
    const char *output_name = NULL;
    char *out_filename = NULL;
    FILE *in;
    int i;

    if (argc < 2)
    {
        fprintf(stderr,"usage: %s input_file [ -o output_file ]\n",argv[0]);
        return 1;
    }

    for (i = 1; i < argc; ++i)
    {
        if (strcmp(argv[i],"-o") == 0 && i + 1 < argc)
            output_name = argv[++i];
        else if (argv[i][0] != '-' && !input_name)
            input_name = argv[i];
    }

    if (!input_name)
    {
        fprintf(stderr,"no input file\n");
        return 1;
    }

    in = fopen(input_name,"r");
    if (!in)
    {
        perror("fopen input");
        return 1;
    }
    yyin = in;

    if (output_name)
        out_filename = strdup(output_name);
    else
    {
        size_t len = strlen(input_name);
        out_filename = malloc(len + 5);
        if (!out_filename)
        {
            perror("malloc");
            fclose(in);
            return 1;
        }
        strcpy(out_filename,input_name);
        char *dot = strrchr(out_filename,'.');
        if (dot)
            strcpy(dot,".asm");
        else
            strcat(out_filename,".asm");
    }

    out_file = fopen(out_filename,"w");
    if (!out_file)
    {
        perror("fopen output");
        fclose(in);
        free(out_filename);
        return 1;
    }

    if (yyparse() != 0)
    {
        fprintf(stderr,"Parsing failed.\n");
        fclose(in);
        fclose(out_file);
        free(out_filename);
        return 1;
    }

    fclose(in);

    if (fclose(out_file) != 0)
    {
        perror("fclose output");
        free(out_filename);
        return 1;
    }

    {
        char cmd[512];
        snprintf(cmd,sizeof(cmd),
                 "nasm -E -f elf64 --include src/semantical.asm \"%s\" > preprocessing.txt",
                 out_filename);
        if (system(cmd) != 0)
        {
            fprintf(stderr,"nasm invocation failed.\n");
            free(out_filename);
            return 1;
        }
    }

    free(out_filename);
    return 0;
}