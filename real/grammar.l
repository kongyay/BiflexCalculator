%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "grammar.tab.h"
extern void yyerror(const char* s,...);
int convHex(char* input);
%}

%%


[0-9A-Fa-f]+[Hh] 	{ yylval = convHex(yytext); return NUM_H; }
[0-9]+ 	            { yylval = atoi(yytext); return NUM; }
[0-9]+"."[0-9]* 	{ yylval = (int)atof(yytext); yyerror("Float/Double are not supported. (Floored to int)"); return NUM;}
[0-9]*"."[0-9]+ 	{ yylval = (int)atof(yytext); yyerror("Float/Double are not supported. (Floored to int)"); return NUM;}


"+"		            {return T_PLUS;}
"-"		            {return T_MINUS;}
"*"		            {return T_MULTIPLY;}
"/"		            {return T_DIVIDE;}
"^"		            {return T_POW;}
\\		            {return T_MOD;}
"AND"|"and"		    {return T_AND;}
"OR"|"or"	        {return T_OR;}
"NOT"|"not"		    {return T_NOT;}

"PUSH"|"push"		{return T_PUSH;}
"POP"|"pop"		    {return T_POP;}
"SHOW"|"show"		{return T_SHOW;}
"LOAD"|"load"		{return T_LOAD;}
"$acc"|"$ACC"       {yylval = 26; return T_REG;}
"$top"|"$TOP"       {yylval = 27; return T_REG;}
"$size"|"$SIZE"     {yylval = 28; return T_REG;}
"$"[rR][A-Za-z]     {yylval = yytext[2]; return T_REG;}
"$"[^ \n]+          {yyerror("Invalid Register \'%s\' ",yytext);}

[Qq][Uu][Ii][Tt]    {return T_QUIT;}
[Ee][Xx][Ii][Tt]    {return T_QUIT;}

"("		            {return T_LEFT;}
")"		            {return T_RIGHT;}
"("[ ]*")"		    {} //ignore empty ( )
\n		            {return T_NEWLINE;}
[ \t]	            {} // ignore whitespace          
.                   {yyerror("Invalid character \'%s\' ",yytext); }
%%
int convHex(char* input) {
    char* p = input;
    while(*p != 'h' && *p != 'H') {
        p++;
    }
    *p = '\0'; 
    return (int)strtol(input, NULL, 16);
}