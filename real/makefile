all: grammar

grammar.tab.c grammar.tab.h:	grammar.y
	bison -d grammar.y

lex.yy.c: grammar.l grammar.tab.h
	flex grammar.l

grammar: lex.yy.c grammar.tab.c grammar.tab.h
	gcc -o grammar grammar.tab.c lex.yy.c -lm

clean:
	rm grammar grammar.tab.c lex.yy.c grammar.tab.h