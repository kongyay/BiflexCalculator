%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
extern int yylex();
extern int yyparse();
extern FILE* yyin;
void yyerror(const char* s);
#define ACC 26
#define TOP 27
#define SIZE 28
%}

%token NUM NUM_H

%token T_PUSH T_POP T_SHOW T_LOAD T_REG

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
%precedence ARG   /* negation--unary minus */

%start calculation

%%

calculation: 
	   		| calculation line
;

line: 		T_NEWLINE
    		| expression T_NEWLINE 			{ printf("\tResult: %d\n", $1); 	setAcc($1);			} 
			| T_SHOW T_REG T_NEWLINE 		{ printf("\tValue: %d\n", getReg($2)); 	}
			| T_LOAD T_REG T_REG T_NEWLINE	{ LoadToReg($2,$3); }
			| T_PUSH T_REG T_NEWLINE	{ pushToSt($2); 							}
			| T_POP T_REG T_NEWLINE	{ popFromSt($2); 								}
;

expression: NUM										{ $$ = $1; 					}
			| NUM_H									{ $$ = $1; 					}
	 		| expression T_PLUS expression			{ $$ = $1 + $3; 			}
			| expression T_MINUS expression			{ $$ = $1 - $3; 			}
			| expression T_MULTIPLY expression		{ $$ = $1 * $3; 			}
			| expression T_DIVIDE expression	 	{ $$ = $1 / $3; 			}
			| expression T_POW expression	 		{ $$ = pow($1, $3); 		}
			| expression T_MOD expression	 		{ $$ = $1 % $3; 			}
			| expression T_AND expression	 		{ $$ = $1 & $3; 			}
			| expression T_OR expression	 		{ $$ = $1 | $3; 			}
			| T_NOT expression	 					{ $$ = ~$2; 				}
			| T_LEFT expression T_RIGHT				{ $$ = $2; 					}
			| T_MINUS expression  %prec NEG 		{ $$ = -$2; 				}

			

			
;

%%
typedef struct node {
    int value;
    struct node * next;
	struct node * prev;
} NODE;
NODE* top;

int reg[26] = {	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 
				'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 
				'W', 'X', 'Y', 'Z' , 0,0,0};
int main() {
	yyin = stdin;
	do {
		yyparse();
	} while(!feof(yyin));
	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Error: %s\n", s);
}

void setAcc(int v) {
	reg[ACC] = v;
}

int rI(int i) {
	i = toupper((char*)i);
	if(i>='A') 
		i = i-'A';
	return i;
}

int getReg(int i) {
	setAcc(reg[rI(i)]);
	return reg[rI(i)];
}

void pushToSt(int i) {	
	NODE* newNode = (NODE*) malloc(sizeof(NODE));
	newNode->value = reg[rI(i)];
	reg[TOP] = reg[rI(i)];
	reg[SIZE]++;
	if(top) {
		newNode->prev = top; 
		top->next = newNode;
	}
		
	top = newNode;
	setAcc(reg[rI(i)]);
} 
void popFromSt(int i) {
	if(top==NULL) {
		yyerror("Stack is empty");
		return;
	}

	if(!LoadToReg(TOP,i)) {
		return;
	}

	if(top->prev) {
		reg[TOP] = top->prev->value;
		top->prev->next = NULL;
	} else {
		reg[TOP] = NULL;
	}
	reg[SIZE]--;
	free(top);
} 


int LoadToReg(int src,int dest) {
	
	src = rI(src);
	dest = rI(dest);
	if(dest<26) {
		reg[dest] = reg[src];
		setAcc(reg[dest]);
		return 1;
	} else {
		yyerror("Read-only register cannot be written");
		return 0;
	}
		
} 




