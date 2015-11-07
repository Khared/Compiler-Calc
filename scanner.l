%{

#include <string.h>
#include "y.tab.h"
#include "global.h"
#include "util.h"
#include "util.c"
extern YYSTYPE yylval;
%}

%option 8bit
%option warn nodefault
%option yylineno noyywrap

id [_a-zA-Z][a-zA-Z0-9_]*
numero [0-9]+("."[0-9]+)*

%%

[\n]	//Ignora o ENTER

[\t ]+	//Ignora o TAB

"if"		return IF;
"else"		return ELSE;
"then"		return THEN;
"while"		return WHILE;
"do"		return DO;
"+"		return MAIS;
"-"		return MENOS;
"*"		return MULT;
"/"		return DIV;
"and"		return AND;
"or"		return OR;
"=="		return IGUAL;
"~="		return NEQ;
"<="		return LE;
">="		return GE;
"<"		return MENOR;
">"		return MAIOR;
"="		return ATRIBUI;
"("		return LPAREN;
")"		return RPAREN;
"end"		return END;

{id}	{
	yylval.token = new_token();
	(yylval.token)->value.name = copy_str(yytext);
	(yylval.token)->lineno = yylineno;
	return ID;
        }

{numero}	{
		yylval.token = new_token();
		(yylval.token)->value.val = atoi(yytext);
		return NUM;
		}

.	printf("Erro lexico [ '%s' ] na linha %d\n", yytext, yylineno);

%%
