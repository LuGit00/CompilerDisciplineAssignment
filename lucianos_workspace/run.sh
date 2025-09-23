#!/bin/bash

bison -d syn.y -o syn.tab.c
flex -o lex.yy.c lex.l
gcc -o out lex.yy.c syn.tab.c
rm lex.yy.c
rm syn.tab.c
rm syn.tab.h
./out
rm out