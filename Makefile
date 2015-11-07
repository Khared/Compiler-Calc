compilador: parser.y scanner.l
	yacc -d parser.y --report all
	lex  scanner.l
	gcc lex.yy.c y.tab.c -lfl -lm
