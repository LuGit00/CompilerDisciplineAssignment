/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_SRC_SYNTACTICAL_TAB_H_INCLUDED
# define YY_YY_SRC_SYNTACTICAL_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    ARRAY = 258,                   /* ARRAY  */
    STRUCT = 259,                  /* STRUCT  */
    PRIVATE = 260,                 /* PRIVATE  */
    PROTECTED = 261,               /* PROTECTED  */
    PUBLIC = 262,                  /* PUBLIC  */
    FUNCTION = 263,                /* FUNCTION  */
    EXECUTE = 264,                 /* EXECUTE  */
    RETURN = 265,                  /* RETURN  */
    LABEL = 266,                   /* LABEL  */
    GOTO = 267,                    /* GOTO  */
    BLOCK = 268,                   /* BLOCK  */
    IF = 269,                      /* IF  */
    ELIF = 270,                    /* ELIF  */
    ELSE = 271,                    /* ELSE  */
    ASSIGN = 272,                  /* ASSIGN  */
    ASSIGN_ADD = 273,              /* ASSIGN_ADD  */
    ASSIGN_SUBTRACT = 274,         /* ASSIGN_SUBTRACT  */
    ASSIGN_MULTIPLY = 275,         /* ASSIGN_MULTIPLY  */
    ASSIGN_IF_LESS_THAN = 276,     /* ASSIGN_IF_LESS_THAN  */
    ASSIGN_IF_MORE_THAN = 277,     /* ASSIGN_IF_MORE_THAN  */
    ASSIGN_IF_LESS_OR_EQUAL_THAN = 278, /* ASSIGN_IF_LESS_OR_EQUAL_THAN  */
    ASSIGN_IF_MORE_OR_EQUAL_THAN = 279, /* ASSIGN_IF_MORE_OR_EQUAL_THAN  */
    ASSIGN_IF_EQUAL = 280,         /* ASSIGN_IF_EQUAL  */
    ASSIGN_IF_NOT_EQUAL = 281,     /* ASSIGN_IF_NOT_EQUAL  */
    ASM = 282,                     /* ASM  */
    ASSIGN_SIZEOF = 283,           /* ASSIGN_SIZEOF  */
    END = 284,                     /* END  */
    ID = 285,                      /* ID  */
    NUMBER = 286,                  /* NUMBER  */
    STRING = 287                   /* STRING  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 18 "src/syntactical.y"

    char *sval;

#line 100 "src/syntactical.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_SRC_SYNTACTICAL_TAB_H_INCLUDED  */
