%{
#include <stdio.h>
#include <stdlib.h>
extern int yylex();
extern int yyparse();
extern FILE* yyin;
void yyerror(const char* s);
%}
%define api.value.type {double}


%token NUM

%token T_PUSH T_POP T_SHOW T_LOAD

%token T_AND T_OR T_NOT T_MOD T_POW
%token T_PLUS T_MINUS T_MULTIPLY T_DIVIDE T_LEFT T_RIGHT T_NEWLINE

%left T_AND
%left T_OR
%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE
%left T_MOD
%left T_NOT
%precedence NEG   /* negation--unary minus */
%right T_POW


%start calculation

%%

calculation: 
	   | calculation line
;

line: T_NEWLINE
    | expression T_NEWLINE { printf("\tResult: %f\n", $1); } 
;

expression: NUM				{ $$ = $1; }
	  | expression T_PLUS expression	{ $$ = $1 + $3; }
	  | expression T_MINUS expression	{ $$ = $1 - $3; }
	  | expression T_MULTIPLY expression	{ $$ = $1 * $3; }
      | expression T_DIVIDE expression	 { $$ = $1 / $3; }
      | expression T_POW expression	 { $$ = pow ($1, $3); }
      | expression T_MOD expression	 { $$ = (int)$1 % (int)$3; }
      | expression T_AND expression	 { $$ = (int)$1 & (int)$3; }
      | expression T_OR expression	 { $$ = (int)$1 | (int)$3; }
      | T_NOT expression	 { $$ = ~(int)$2; }
	  | T_LEFT expression T_RIGHT		{ $$ = $2; }
      | T_MINUS expression  %prec NEG { $$ = -$2;          }
;

%%
int main() {
	yyin = stdin;
	do { 
		yyparse();
	} while(!feof(yyin));
	return 0;
}
void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}