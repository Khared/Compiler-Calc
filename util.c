#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "global.h"
#include "util.h"
#include "y.tab.h"

static int indent_level = 0;

struct node_t *new_expr_node(enum expr_kind kind)
{
	struct node_t *n = (struct node_t *) malloc (sizeof (struct node_t));
	int i;

	for(i=0 ; i<3; i++)
		n->child[i] = NULL;
	n->next = NULL;
	n->lineno = 0;
	n->kind = expr_k;
	n->type.expr = kind;
	n->attr.name = NULL;
	return n;
}

struct node_t *new_stmt_node(enum stmt_kind kind)
{
	struct node_t *n = (struct node_t *) malloc(sizeof(struct node_t));
	int i;

	for(i=0 ; i<3; i++)
		n->child[i] = NULL;
	n->next = NULL;
	n->lineno = 0;
	n->kind = stmt_k;
	n->type.stmt = kind;
	return n;
}

struct token_t *new_token(void) {
	struct token_t *t = (struct token_t *) malloc (sizeof (struct token_t));
	return t;
}

void print_node(struct node_t *node) {
	int i;

	for (i = 0 ; i < indent_level ; i++)
		fprintf(stderr, "  ");

	if (node == NULL)
		return;
	switch (node->kind) {
		case stmt_k:
			fprintf(stderr, "Stament: ");
			switch (node->type.stmt) {
				case if_k:
					fprintf(stderr, "IF\n"); break;
				case attrib_k:
					fprintf(stderr, "ATTRIB to %s\n", node->attr.name); break;
				case while_k:
					fprintf(stderr, "WHILE\n"); break;
			}
			break;
		case expr_k:
			fprintf(stderr, "Expression: ");
			switch (node->type.expr){
				case id_k:
					fprintf(stderr, "ID: %s\n", node->attr.name); break;
				case op_k:
					fprintf(stderr, "OP: ");
					switch (node->attr.op) {
						case AND:
							fprintf(stderr, "&&"); break;
						case OR:
							fprintf(stderr, "||"); break;
						case IGUAL:
							fprintf(stderr, "=="); break;
						case NEQ:
							fprintf(stderr, "~="); break;
						case GE:
							fprintf(stderr, ">="); break;
						case MAIOR:
							fprintf(stderr, ">"); break;
						case LE:
							fprintf(stderr, "<="); break;
						case MENOR:
							fprintf(stderr, "<"); break;
						case MAIS:
							fprintf(stderr, "+"); break;
						case MENOS:
							fprintf(stderr, "-"); break;
						case MULT:
							fprintf(stderr, "*"); break;
						case DIV:
							fprintf(stderr, "/"); break;
					}
					fprintf(stderr, "\n");
					break;
				case const_k:
					fprintf(stderr, "NUM: %d\n", node->attr.val); break;
			}
			break;
	}
	return;
}

char *copy_str (char *str) {
	char *aux;
	int len = 0;
	len = strlen(str) + 1;
	aux = (char *) malloc (len);
	memset(aux, 0, len);
	memcpy(aux, str, len - 1);
	return aux;
}

void print_tree (struct node_t *node) {
	static int first = 1;
	int i = 0;

	if (first){
		fprintf (stderr, "\n======== Printing AST ========\n");
		first = 0;
	}

	if (node != NULL) {
		print_node(node);
		for (i = 0 ; i < MAX_CHILDREN ; i++)
			if (node->child[i]) {
				indent_level++;
				print_tree(node->child[i]);
				indent_level--;
			}
		if (node->next != NULL)
			print_tree(node->next);
	}
	return;
}
