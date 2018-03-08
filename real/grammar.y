%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <math.h>
#include <stdarg.h>
extern int yylex();
extern int yyparse();
extern FILE* yyin;
void yyerror(const char* s,...);
void setAcc(int v);
int rI(int i);
int getReg(int i);
void pushToSt(int i);
void pushToSt_v(int i);
void popFromSt(int i);
int LoadToReg(int src,int dest);
int LoadToReg_v(int src,int dest);
#define ACC 26
#define TOP 27
#define SIZE 28
%}

%token NUM NUM_H							//ประกาศ token
%token T_PUSH T_POP T_SHOW T_LOAD T_REG

%token T_NEWLINE T_QUIT
// เรียงลำดับความสำคัญของ token ต่างๆ

%nonassoc LOW; // token มีไว้ให้ rule อ้างอิงถึงกรณีที่ต้องการให้ความสำคัญหลังสุด
%left T_AND // AND กระทำจากซ้ายไปขวา
%left T_OR  // OR กระทำจากซ้ายไปขวา
%left T_PLUS T_MINUS // + - กระทำจากซ้ายไปขวา
%left T_MULTIPLY T_DIVIDE // * / กระทำจากซ้ายไปขวา
%left T_MOD // \ กระทำจากซ้ายไปขวา
%left T_NOT // NOT กระทำจากซ้ายไปขวา

%left T_LEFT // วงเล็บ ()
%left T_RIGHT 


%precedence NEG // token NEG มีไว้ให้ rule เลขติดลบอ้างถึง กรณีที่ให้ความสำคัญทำก่อน operation exp-exp
%right T_POW // ^ กระทำจากซ้ายไปขวา

%start calculation // S -> ....

%%

calculation: 
	   		| calculation line { printf("> "); } // ทุกครั้งที่คำนวณเสร็จ 1 บรรทัด (Reduce จน accept ได้) ให้ print >

;

line: 		T_NEWLINE								
    		| exp T_NEWLINE 				{ printf("\tResult: %d\n", $1); 	setAcc($1);			} 
			| T_SHOW T_REG T_NEWLINE 		{ printf("\tValue: %d\n", getReg($2)); 					}
			| T_LOAD exp T_REG T_NEWLINE	{ LoadToReg_v($2,$3); 						}
			| T_PUSH exp T_NEWLINE			{ pushToSt_v($2); 							}
			| T_POP T_REG T_NEWLINE			{ popFromSt($2); 										}
			| T_QUIT T_NEWLINE 				{ exit(0); }

			| T_SHOW error T_NEWLINE 				{ yyerror("Usage: SHOW $<reg.>"); 	yyerrok; 								}
			| T_LOAD error T_NEWLINE				{ yyerror("Usage: LOAD <$src. reg.>|<exp.> <$dest reg.>"); 		yyerrok; 	}
			| T_PUSH error T_NEWLINE				{ yyerror("Usage: PUSH $<src. reg.>"); 		yyerrok; 						}
			| T_POP error T_NEWLINE					{ yyerror("Usage: POP $<src reg.> $<dest. reg.>"); 		yyerrok; 			}

			
			| T_LEFT exp error T_NEWLINE			{ yyerror("Missing Right Parenthesis"); 	yyerrok;			} 
			| T_LEFT error T_NEWLINE 				{ yyerror("Missing Right Parenthesis"); 	yyerrok;			} 
			| error exp T_RIGHT error T_NEWLINE 	{ yyerror("Missing Left Parenthesis"); 	yyerrok;				}
			| error T_RIGHT error T_NEWLINE 		{ yyerror("Missing Left Parenthesis"); 	yyerrok;				}
				
			| error exp T_NEWLINE 				{ yyerror("Missing Operator/Operand"); 	yyerrok;	} 
			| error T_NEWLINE					{ yyerror("Missing Operator/Operand"); yyerrok;		}	
;

exp: NUM							{ $$ = $1; 				}
			| NUM_H					{ $$ = $1; 				}
			| T_REG					{ $$ = getReg($1);		}
	 		| exp T_PLUS exp		{ $$ = $1 + $3; 		}
			| exp T_MINUS exp		{ $$ = $1 - $3; 		}
			| exp T_MULTIPLY exp	{ $$ = $1 * $3; 		}
			| exp T_DIVIDE exp	 	{ if($3!=0) $$ = $1/$3; else {$$ = $1; 	yyerror("Cannot Divide by zero, Result skips /0 calculation");}		}
			| exp T_MOD exp	 		{ if($3!=0) $$ = $1%$3; else {$$ = $1;	yyerror("Cannot Divide by zero, Result skips \\0 calculation");}	}
			| exp T_POW exp	 		{ $$ =(int)pow($1, $3);	}
			| exp T_AND exp	 		{ $$ = $1 & $3; 		}
			| exp T_OR exp	 		{ $$ = $1 | $3; 		}
			| T_NOT exp	 			{ $$ = ~$2; 			}
			| T_LEFT exp T_RIGHT	{ $$ = $2; 				}
			| T_MINUS exp  %prec NEG{ $$ = -$2; 			}
			
;

%%
typedef struct node {
    int value;
    struct node * next;
	struct node * prev;
} NODE;
NODE* top;

int reg[29] = {0};

// main function
int main() {
	printf("================= CALCULATOR ==============\n> ");
	// Loop parse ในกรณี input file
	yyin = stdin;
	do {
		yyparse();
	} while(!feof(yyin));
	return 0;
}

// error display function
void yyerror(const char* s,...) {
	va_list ap;
	va_start(ap,s);
	fprintf(stderr, "Error: ");
	vfprintf(stderr, s, ap);
	fprintf(stderr, "\n");
}

// set $acc function
void setAcc(int v) {
	reg[ACC] = v;
}

// register resolving function $rA -> r[0]
int rI(int i) {
	i = toupper(i);
	if(i>='A') 
		i = i-'A';
	return i;
}

// register bank access function
int getReg(int i) {
	// หากเรียกดู $top ให้ Check stack ว่างโดยใช้ register $size มาเช็ค
	if(i==TOP && reg[SIZE]==0) {
		yyerror("Stack is empty. Result is an old $top");
		return 0;
	}
		
	return reg[rI(i)];
}

// push register->stack  function
void pushToSt(int i) {	
	// เช็คก่อนว่ามีการเรียกใช้ top หรือไม่ หากว่างต้องไม่ควร push top ได้
	if(i==TOP && reg[SIZE]==0) {
		yyerror("Stack is empty. Pushing $top is canceled");
		return;
	}
	NODE* newNode = (NODE*) malloc(sizeof(NODE));
	newNode->value = reg[rI(i)];
	reg[TOP] = reg[rI(i)];
	reg[SIZE]++;
	
	if(top) { // เช็คว่ามี top หรือยัง หากมีแล้วให้เชื่อมกับ top ก่อนหน้าด้วย
		newNode->prev = top; 
		top->next = newNode;
	}
		
	top = newNode;
	setAcc(reg[rI(i)]);
} 
// push value->stack  function
void pushToSt_v(int val) {	
	NODE* newNode = (NODE*) malloc(sizeof(NODE));
	newNode->value = val;
	reg[TOP] = val;
	reg[SIZE]++;
	
	if(top) { // เช็คว่ามี top หรือยัง หากมีแล้วให้เชื่อมกับ top ก่อนหน้าด้วย
		newNode->prev = top; 
		top->next = newNode;
	}
		
	top = newNode;
	setAcc(val);
} 

// stack pop function
void popFromSt(int i) {
	if(reg[SIZE]==0) {
		yyerror("Stack is empty.");
		return;
	}

	// เรียกใช้ load เพื้อเป็นการเช็ค read-only register ไปในตัว
	if(!LoadToReg(TOP,i)) {
		return;
	}

	
	if(top->prev) { // ย้าย top pointer ถ้ายังไม่ใช่ bottom
		reg[TOP] = top->prev->value;
		top->prev->next = NULL;
		top = top->prev;
		free(top->next);
	} else { 	// ถ้าเป็น bottom ไม่จำเป็นต้องย้าย
		free(top);
	}

	// ลด $size
	reg[SIZE]--;
	
} 

// load register->register  function 
int LoadToReg(int src,int dest) {
	// ทำการแปลง index ก่อน
	src = rI(src);
	dest = rI(dest);
	
	// เช็ค read-only register
	if(dest<26) {
		// เช็คก่อนว่ามีการเรียกใช้ top หรือไม่ หากว่างต้องไม่ควร load top ได้
		if(src==TOP && reg[SIZE]==0) {
			yyerror("Stack is empty. Loading $top is cancelled");
			return 0;
		}

		reg[dest] = reg[src];
		setAcc(reg[dest]);
		return 1;
	} else {
		yyerror("Read-only register cannot be written");
		return 0;
	}
		
} 

// load value->register  function 
int LoadToReg_v(int val,int dest) {
	// ทำการแปลง index ก่อน
	dest = rI(dest);
	// เช็ค read-only register
	if(dest<26) {
		reg[dest] = val;
		setAcc(val);
		return 1;
	} else {
		yyerror("Read-only register cannot be written");
		return 0;
	}
		
} 




