%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "grammar.tab.h"

%}

%%

[ \t]	; // ignore all whitespace
[0-9]+(\.[0-9]+)? 	{yylval = atof(yytext); return NUM;}
[0-9]+(\.[0-9]+)? 	{yylval = atof(yytext); return NUM;}
\n		{return T_NEWLINE;}
"+"		{return T_PLUS;}
"-"		{return T_MINUS;}
"*"		{return T_MULTIPLY;}
"/"		{return T_DIVIDE;}
"("		{return T_LEFT;}
")"		{return T_RIGHT;}
"^"		{return T_POW;}

"AND"		{return T_AND;}
"OR"		{return T_OR;}
"NOT"		{return T_NOT;}
\\		{return T_MOD;}

"PUSH"		{return T_PUSH;}
"POP"		{return T_POP;}
"SHOW"		{return T_SHOW;}
"LOAD"		{return T_LOAD;}

%%