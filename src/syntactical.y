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

%token ARRAY STRUCT PRIVATE PROTECTED PUBLIC FUNCTION EXECUTE RETURN LABEL GOTO BLOCK IF ELIF ELSE ASSIGN ASSIGN_ADD ASSIGN_SUBTRACT ASSIGN_MULTIPLY ASSIGN_IF_LESS_THAN ASSIGN_IF_MORE_THAN ASSIGN_IF_LESS_OR_EQUAL_THAN ASSIGN_IF_MORE_OR_EQUAL_THAN ASSIGN_IF_EQUAL ASSIGN_IF_NOT_EQUAL ASM ASSIGN_SIZEOF END
%token <sval> ID
%token <sval> NUMBER
%token <sval> STRING

%type <sval> num_str_id

%start global_scope

%%

array_declaration :
    ARRAY ID NUMBER
        { fprintf(out_file,"array %s, %s\n", $2, $3); }
    ;

inherit_ids :
      ID
        { fprintf(out_file,", %s", $1); }
    | inherit_ids ID
        { fprintf(out_file,", %s", $2); }
    ;

opt_inherit_ids :
        { fprintf(out_file, "\n"); }
    | inherit_ids
        { fprintf(out_file, "\n"); }
    ;

end_ids :
      ID
        { fprintf(out_file," %s", $1); }
    | end_ids ID
        { fprintf(out_file,", %s", $2); }
    ;

opt_end_ids :
        { fprintf(out_file, "\n"); }
    | end_ids
        { fprintf(out_file, "\n"); }
    ;

num_str_id :
      NUMBER
    | STRING
    | ID
    ;

stmt :
      array_declaration
    | struct_declaration
    | function_declaration

    | EXECUTE ID
        { fprintf(out_file,"execute %s\n", $2); }

    | RETURN
        { fprintf(out_file,"return\n"); }

    | LABEL ID
        { fprintf(out_file,"label %s\n", $2); }

    | GOTO ID
        { fprintf(out_file,"goto %s\n", $2); }

    | BLOCK
        { fprintf(out_file,"block\n"); }

    | IF num_str_id
        { fprintf(out_file,"if %s\n", $2); }

    | ELIF num_str_id
        { fprintf(out_file,"elif %s\n", $2); }

    | ELSE
        { fprintf(out_file,"else\n"); }

    | ASSIGN ID num_str_id
        { fprintf(out_file,"assign %s, %s\n", $2, $3); }

    | ASSIGN_ADD ID num_str_id num_str_id
        { fprintf(out_file,"assign_add %s, %s, %s\n", $2, $3, $4); }

    | ASSIGN_SUBTRACT ID num_str_id num_str_id
        { fprintf(out_file,"assign_subtract %s, %s, %s\n", $2, $3, $4); }

    | ASSIGN_MULTIPLY ID num_str_id num_str_id
        { fprintf(out_file,"assign_multiply %s, %s, %s\n", $2, $3, $4); }

    | ASSIGN_IF_LESS_THAN ID num_str_id num_str_id
        { fprintf(out_file,"assign_if_less_than %s, %s, %s\n", $2, $3, $4); }

    | ASSIGN_IF_MORE_THAN ID num_str_id num_str_id
        { fprintf(out_file,"assign_if_more_than %s, %s, %s\n", $2, $3, $4); }

    | ASSIGN_IF_LESS_OR_EQUAL_THAN ID num_str_id num_str_id
        { fprintf(out_file,"assign_if_less_or_equal_than %s, %s, %s\n", $2, $3, $4); }

    | ASSIGN_IF_MORE_OR_EQUAL_THAN ID num_str_id num_str_id
        { fprintf(out_file,"assign_if_more_or_equal_than %s, %s, %s\n", $2, $3, $4); }

    | ASSIGN_IF_EQUAL ID num_str_id num_str_id
        { fprintf(out_file,"assign_if_equal %s, %s, %s\n", $2, $3, $4); }

    | ASSIGN_IF_NOT_EQUAL ID num_str_id num_str_id
        { fprintf(out_file,"assign_if_not_equal %s, %s, %s\n", $2, $3, $4); }

    | ASM STRING
        { fprintf(out_file,"asm %s\n", $2); }

    | ASSIGN_SIZEOF ID ID
        { fprintf(out_file,"assign_sizeof %s, %s\n", $2, $3); }
    ;

struct_body :
        /* empty */
    | struct_body stmt
    ;

struct_declaration :
    STRUCT ID
        { fprintf(out_file,"struct %s", $2); }
    opt_inherit_ids
    struct_body
    END
        { fprintf(out_file,"end"); }
    opt_end_ids
    ;

function_body :
        /* empty */
    | function_body stmt
    ;

function_declaration :
    FUNCTION ID
        { fprintf(out_file,"function %s\n", $2); }
    function_body
    END
        { fprintf(out_file,"end\n"); }
    ;

global_scope :
        /* empty */
    | global_scope stmt
    ;

%%

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

int yyparse(void);

int main(int argc, char **argv)
{
    const char *input_name = NULL;
    const char *output_name = NULL;
    char *out_filename = NULL;
    FILE *in;
    int i;

    if (argc < 2)
    {
        fprintf(stderr,"usage: %s input_file [ -o output_file ]\n", argv[0]);
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
        strcpy(out_filename, input_name);
        char *dot = strrchr(out_filename, '.');
        if (dot)
            strcpy(dot, ".asm");
        else
            strcat(out_filename, ".asm");
    }

    out_file = fopen(out_filename, "w");
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
        char *obj_name = NULL;
        char *exe_name = NULL;
        char *dot;
        size_t base_len;

        /* strip extension from out_filename */
        dot = strrchr(out_filename, '.');
        if (dot)
            base_len = (size_t)(dot - out_filename);
        else
            base_len = strlen(out_filename);

        /* base + ".o" + '\0' */
        obj_name = malloc(base_len + 3);
        /* base + '\0' */
        exe_name = malloc(base_len + 1);

        if (!obj_name || !exe_name)
        {
            perror("malloc");
            free(obj_name);
            free(exe_name);
            free(out_filename);
            return 1;
        }

        memcpy(obj_name, out_filename, base_len);
        obj_name[base_len] = '\0';
        strcpy(obj_name + base_len, ".o");  /* now "<base>.o" */

        memcpy(exe_name, out_filename, base_len);
        exe_name[base_len] = '\0';         /* now "<base>" */

        /* assemble: nasm -f elf64 -o "<base>.o" out_filename */
        snprintf(cmd, sizeof(cmd),
                 "nasm -f elf64 -o \"%s\" --include src/semantical.asm \"%s\"",
                 obj_name, out_filename);
        if (system(cmd) != 0)
        {
            fprintf(stderr, "nasm invocation failed.\n");
            free(obj_name);
            free(exe_name);
            free(out_filename);
            return 1;
        }

        /* link: ld -o "<base>" "<base>.o" */
        snprintf(cmd, sizeof(cmd),
                 "ld -o \"%s\" \"%s\"",
                 exe_name, obj_name);
        if (system(cmd) != 0)
        {
            fprintf(stderr, "ld invocation failed.\n");
            free(obj_name);
            free(exe_name);
            free(out_filename);
            return 1;
        }

        free(obj_name);
        free(exe_name);
    }

    free(out_filename);
    return 0;
}
