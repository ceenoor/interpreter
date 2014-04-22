%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"
%}

%option noyywrap

%%
" " {}
%.*$ {}
\n      {}
"input"  {return INPUT;}
"print"  {return PRINT;}
"do"     {return DO;}
"while"  {return WHILE;}
"else"   {return ELSE;}
"then"   {return THEN;}
"if"     {return IF;}
"end"    {return END;}
"begin"  {return BEGINS;}
\)       {return RPAREN;}
\(       {return LPAREN;}
":="     {return CEQUAL;}
";"      {return SCOL;}
"||"     {return OR;}
"&&"     {return AND;}
"!="     {return NEQUALS;}
"!"      {return NOT;}
"=="     {return EQUALS;}
">="     {return GREATEREQ;}
"<="     {return LESSEQ;}
">"      {return GREATER;}
"<"      {return LESS;}
\*       {return TIMES;}
\+       {return PLUS;}
"-"      {return MINUS;}
"/"      {return DIVIDE;}
[_a-zA-Z][_A-Za-z0-9]*  {strcpy(yylval.text,yytext); return IDENT;}
[0-9]+(\.[0-9]+)?|(\.[0-9]+)?    {yylval.value = atof(yytext); return VAL;}
.        {printf("Error: invlaid lexeme '%s'.\n", yytext); return 0;}
%%

