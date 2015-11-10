/* Geração da Tabela de Simbolos */
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

struct Simbolo{
    char identificador[50]; /* nome do simbolo */
    int val;          /* valor do simbolo  */
    struct Simbolo *next;  /* ponteiro para o próximo  */
};

typedef struct Simbolo Simbolo;

Simbolo *sym_table;

bool setsimbolo (char *sym_id, int sym_val, int *sym_mem){ /* Função para colocar uma variável na tabela */
	Simbolo *temporario;
	if(temporario = (Simbolo*)malloc(sizeof(Simbolo))){
        strcpy (temporario->identificador, sym_id);
        temporario->val = sym_val;
        temporario->next = (struct Simbolo *) sym_table;
        sym_table = temporario;
        return true;}
	else
        return false;
}
Simbolo *getsimbolo (char *sym_id) { /* Busca de variável na tabela */
    Simbolo *temporario;
    for(temporario = sym_table; temporario != NULL; temporario = temporario->next)
        if((strcmp(temporario->identificador,sym_id)) == 0)
            return temporario;
    return NULL;
}
void inicializatabela(){
    sym_table = NULL;
}

