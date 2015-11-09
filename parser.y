%{
#include <stdlib.h>
#include <stdio.h>
#include "global.h"
#include "util.h"
//#include "util.c"
//#include "symtab.h"
#include "symtab.c"

int yylex(void);
void yyerror(const char *, ...);

int lineno;
char *saved_name;
%}

%union {
	struct token_t *token;
	struct node_t *node;
}

%token AND ATRIBUI ELSE END IGUAL GE MAIOR IF LE LPAREN MENOR THEN DO ;
%token MENOS NEQ OR DIV MAIS RPAREN MULT ;
%token WHILE ;
%token <val> NUM;
%token <name> ID;

%type <node> stmts stmt while_decl if_decl atrb_decl ;
%type <node> bool expr factor;

%left IGUAL NEQ;
%left GE MAIOR LE MENOR;
%left MULT DIV;
%left MAIS MENOS;
%left LPAREN;
%nonassoc ATRIBUI;

%%

program : stmts { ast = $1; }
        ;

stmts : stmts stmt
	{
	  struct node_t *t = $1;
	  if (t != NULL) {
	  while (t->next != NULL)
		t = t->next;
		t->next = $2;
		$$ = $1;
	  } else
		$$ = $2;
         }
      | stmt
        { $$ = $1; }
      ;

stmt  : if_decl
        { $$ = $1; }
      | while_decl
        { $$ = $1; }
      | atrb_decl
        { $$ = $1; }
      ;

if_decl  : IF LPAREN bool RPAREN THEN stmts END
           {
             $$ = new_stmt_node(if_k);
             $$->child[0] = $3;
             $$->child[1] = $6;
           }
         | IF LPAREN bool RPAREN THEN stmts ELSE stmts END
           {
             $$ = new_stmt_node(if_k);
             $$->child[0] = $3;
             $$->child[1] = $6;
             $$->child[2] = $8;
           }
         ;

while_decl : WHILE LPAREN bool RPAREN DO stmts END
           {
             $$ = new_stmt_node(while_k);
             $$->child[0] = $3;
             $$->child[1] = $6;
           }
           ;

atrb_decl : ID
            {
              saved_name = copy_str ((yylval.token)->value.name);
              lineno = yylval.token->lineno;
            }
            ATRIBUI expr
            {
              $$ = new_stmt_node(attrib_k);
              $$->child[0] = $4;
              $$->attr.name = saved_name;
              $$->lineno = lineno;
              symtab_insert(stab, saved_name);
            }
            ;

expr : expr MAIS expr
     {
       $$ = new_expr_node(op_k);
       $$->child[0] = $1;
       $$->child[1] = $3;
       $$->attr.op = MAIS;
     }
     | expr MENOS expr
     {
       $$ = new_expr_node(op_k);
       $$->child[0] = $1;
       $$->child[1] = $3;
       $$->attr.op = MENOS;
     }
     | expr MULT expr
     {
       $$ = new_expr_node(op_k);
       $$->child[0] = $1;
       $$->child[1] = $3;
       $$->attr.op = MULT;
     }
     | expr DIV expr
     {
       $$ = new_expr_node(op_k);
       $$->child[0] = $1;
       $$->child[1] = $3;
       $$->attr.op = DIV;
     }
     | factor
       { $$ = $1; }
     | bool
       { $$ = $1; }
     ;

bool : expr OR expr
       {
          $$ = new_expr_node(op_k);
          $$->child[0] = $1;
          $$->child[1] = $3;
          $$->attr.op  = OR;
       }
     | expr AND expr
       {
          $$ = new_expr_node(op_k);
          $$->child[0] = $1;
          $$->child[1] = $3;
          $$->attr.op  = AND;
       }
     | expr IGUAL expr
       {
          $$ = new_expr_node(op_k);
          $$->child[0] = $1;
          $$->child[1] = $3;
          $$->attr.op  = IGUAL;
       }
     | expr NEQ expr
       {
          $$ = new_expr_node(op_k);
          $$->child[0] = $1;
          $$->child[1] = $3;
          $$->attr.op  = NEQ;
       }
     | expr MAIOR expr
       {
          $$ = new_expr_node(op_k);
          $$->child[0] = $1;
          $$->child[1] = $3;
          $$->attr.op  = MAIOR;
       }
     | expr MENOR expr
       {
          $$ = new_expr_node(op_k);
          $$->child[0] = $1;
          $$->child[1] = $3;
          $$->attr.op  = MENOR;
       }
     | expr GE expr
       {
          $$ = new_expr_node(op_k);
          $$->child[0] = $1;
          $$->child[1] = $3;
          $$->attr.op  = GE;
       }
     | expr LE expr
       {
          $$ = new_expr_node(op_k);
          $$->child[0] = $1;
          $$->child[1] = $3;
          $$->attr.op  = LE;
       }
     | expr
       { $$ = $1; }
     ;

factor : LPAREN expr RPAREN
       { $$ = $2; }
       | ID
         {
           struct symtab_t *symbol = NULL;
           $$ = new_expr_node(id_k);
           $$->attr.name = copy_str ((yylval.token)->value.name);
           $$->lineno = yylval.token->lineno;
           symbol = symtab_lookup(stab, (yylval.token)->value.name);
           if ( symbol == NULL )
           {
             fprintf(stderr,"Erro sintatico: Simbolo '%s' nao existe, linha %d.\n", (yylval.token)->value.name, yylval.token->lineno);
             exit(EXIT_FAILURE);
           }
         }
       | NUM
         {
           $$ = new_expr_node(const_k);
           $$->attr.val = (yylval.token)->value.val;
         }
       ;
%%

void yyerror(const char * s, ...) {
	printf("Erro sintatico: %s\n", s);
	return;
}

int main() {
	if (yyparse())
		fprintf(stderr, "Successful parsing.\n");
	else
		fprintf(stderr, "error found.\n");
	return 0;
}
