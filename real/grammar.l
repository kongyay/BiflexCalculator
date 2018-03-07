%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "grammar.tab.h"
extern int yyerror(const char* s);
int convHex(char* input);
%}

%%

[ \t]	; // ignore all whitespace
[0-9A-Fa-f]+[Hh] 	{ yylval = convHex(yytext); return NUM_H; }
[0-9]+ 	            { yylval = atoi(yytext); return NUM; }
[0-9]+"."[0-9]* 	{ yyerror("Float/Double are not supported."); }
[0-9]*"."[0-9]+ 	{ yyerror("Float/Double are not supported."); }

\n		            {return T_NEWLINE;}
"+"		            {return T_PLUS;}
"-"		            {return T_MINUS;}
"*"		            {return T_MULTIPLY;}
"/"		            {return T_DIVIDE;}
"("		            {return T_LEFT;}
")"		            {return T_RIGHT;}
"^"		            {return T_POW;}

"AND"		        {return T_AND;}
"OR"		        {return T_OR;}
"NOT"		        {return T_NOT;}
\\		            {return T_MOD;}

"PUSH"|"push"		{return T_PUSH;}
"POP"|"pop"		    {return T_POP;}
"SHOW"|"show"		{return T_SHOW;}
"LOAD"|"load"		{return T_LOAD;}
"$acc"|"$ACC"       {yylval = 26; return T_REG;}
"$top"|"$TOP"       {yylval = 27; return T_REG;}
"$size"|"$SIZE"     {yylval = 28; return T_REG;}
"$"[rR][A-Za-z]     {yylval = yytext[2]; return T_REG;}
.                   { yyerror("invalid character:"); }
%%


int convHex(char* input) {
    char* p = input;
    while(*p != 'h' && *p != 'H') {
        p++;
    }
    *p = '\0'; 
    return (int)strtol(input, NULL, 16);
}