#include "tac.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Variável global para contagem de rótulos e temporários
static int label_count = 0;
static int temp_count = 0;

// Função para gerar um novo rótulo
char *new_label() {
    char *label = (char *)malloc(sizeof(char) * 16);
    sprintf(label, "L%d", label_count++);
    return label;
}

// Função para gerar uma nova variável temporária
char *new_temp() {
    char *temp = (char *)malloc(sizeof(char) * 16);
    sprintf(temp, "t%d", temp_count++);
    return temp;
}

TAC *create_tac(TACOp op, char *arg1, char *arg2, char *result) {
    TAC *new_tac = (TAC *)malloc(sizeof(TAC));
    if (!new_tac) {
        perror("Failed to allocate TAC");
        exit(EXIT_FAILURE);
    }
    new_tac->op = op;
    new_tac->arg1 = arg1 ? strdup(arg1) : NULL;
    new_tac->arg2 = arg2 ? strdup(arg2) : NULL;
    new_tac->result = result ? strdup(result) : NULL;
    new_tac->next = NULL;
    return new_tac;
}

void print_tac(TAC *tac) {
    while (tac) {
        switch (tac->op) {
            case TAC_ADD:
                printf("%s = %s + %s\n", tac->result, tac->arg1, tac->arg2);
                break;
            case TAC_SUB:
                printf("%s = %s - %s\n", tac->result, tac->arg1, tac->arg2);
                break;
            case TAC_MUL:
                printf("%s = %s * %s\n", tac->result, tac->arg1, tac->arg2);
                break;
            case TAC_DIV:
                printf("%s = %s / %s\n", tac->result, tac->arg1, tac->arg2);
                break;
            case TAC_ASSIGN:
                printf("%s = %s\n", tac->result, tac->arg1);
                break;
            case TAC_IF_EQ:
                printf("IF %s == %s GOTO %s\n", tac->arg1, tac->arg2, tac->result);
                break;
            case TAC_IF_NE:
                printf("IF %s != %s GOTO %s\n", tac->arg1, tac->arg2, tac->result);
                break;
            case TAC_IF_LT:
                printf("IF %s < %s GOTO %s\n", tac->arg1, tac->arg2, tac->result);
                break;
            case TAC_IF_GT:
                printf("IF %s > %s GOTO %s\n", tac->arg1, tac->arg2, tac->result);
                break;
            case TAC_IF_LE:
                printf("IF %s <= %s GOTO %s\n", tac->arg1, tac->arg2, tac->result);
                break;
            case TAC_IF_GE:
                printf("IF %s >= %s GOTO %s\n", tac->arg1, tac->arg2, tac->result);
                break;
            case TAC_GOTO:
                printf("GOTO %s\n", tac->result);
                break;
            case TAC_LABEL:
                printf("%s:\n", tac->result);
                break;
            case TAC_RETURN:
                printf("RETURN %s\n", tac->result);
                break;
            case TAC_VAR_DECL:
                printf("VAR %s\n", tac->result);
                break;
            case TAC_PRINT:
                printf("PRINT %s\n", tac->result);
                break;
            default:
                printf("UNKNOWN_TAC_OP\n");
                break;
        }
        tac = tac->next;
    }
}

// Função para concatenar listas de TAC
TAC *concat_tac(TAC *tac1, TAC *tac2) {
    if (!tac1) return tac2;
    if (!tac2) return tac1;
    TAC *current = tac1;
    while (current->next) {
        current = current->next;
    }
    current->next = tac2;
    return tac1;
}

// Função principal para gerar TAC a partir da AST
TAC *generate_tac(ASTNode *node) {
    if (!node) return NULL;

    TAC *tac_list = NULL;
    TAC *left_tac = NULL;
    TAC *right_tac = NULL;
    TAC *middle_tac = NULL;
    TAC *next_tac = NULL;
    char *temp_result = NULL;
    char *label_true = NULL;
    char *label_false = NULL;
    char *label_next = NULL;

    switch (node->type) {
        case NODE_PROGRAM:
            tac_list = generate_tac(node->left); // function_definition_list
            break;
        case NODE_FUNCTION_DEFINITION:
            // Para cada função, gerar um rótulo para o início da função
            tac_list = create_tac(TAC_LABEL, NULL, NULL, node->right->value); // ID da função
            tac_list = concat_tac(tac_list, generate_tac(node->middle)); // statement_list
            break;
        case NODE_STATEMENT_LIST:
            tac_list = generate_tac(node->left); // statement
            tac_list = concat_tac(tac_list, generate_tac(node->next)); // next statement
            break;
        case NODE_DECLARATION:
            tac_list = create_tac(TAC_VAR_DECL, NULL, NULL, node->right->value); // ID da variável
            break;
        case NODE_ASSIGNMENT:
            right_tac = generate_tac(node->right); // Expressão à direita
            temp_result = right_tac ? right_tac->result : node->right->value; // Se for um número ou ID direto
            tac_list = concat_tac(right_tac, create_tac(TAC_ASSIGN, temp_result, NULL, node->left->value)); // ID da variável
            break;
        case NODE_ADD:
        case NODE_SUB:
        case NODE_MUL:
        case NODE_DIV:
            left_tac = generate_tac(node->left);
            right_tac = generate_tac(node->right);
            temp_result = new_temp();
            tac_list = concat_tac(left_tac, right_tac);
            TACOp op;
            if (node->type == NODE_ADD) op = TAC_ADD;
            else if (node->type == NODE_SUB) op = TAC_SUB;
            else if (node->type == NODE_MUL) op = TAC_MUL;
            else op = TAC_DIV;
            tac_list = concat_tac(tac_list, create_tac(op, left_tac->result, right_tac->result, temp_result));
            // O resultado da expressão é o temporário gerado
            node->value = temp_result; // Armazena o temporário no nó da AST para uso posterior
            break;
        case NODE_NUMBER:
        case NODE_ID:
            // Para números e IDs, o 'resultado' é o próprio valor/nome
            node->value = strdup(node->value); // Duplica para evitar liberar a string original
            break;
        case NODE_EQ:
        case NODE_NE:
        case NODE_LT:
        case NODE_GT:
        case NODE_LE:
        case NODE_GE:
            left_tac = generate_tac(node->left);
            right_tac = generate_tac(node->right);
            tac_list = concat_tac(left_tac, right_tac);
            // O resultado da expressão relacional é o temporário gerado
            node->value = new_temp(); // Armazena o temporário no nó da AST para uso posterior
            break;
        case NODE_IF:
            label_true = new_label();
            label_next = new_label();
            left_tac = generate_tac(node->left); // Condição
            middle_tac = generate_tac(node->middle); // Bloco IF

            tac_list = left_tac;
            // Adicionar TAC condicional
            if (node->left->type == NODE_EQ) tac_list = concat_tac(tac_list, create_tac(TAC_IF_EQ, left_tac->arg1, left_tac->arg2, label_true));
            else if (node->left->type == NODE_NE) tac_list = concat_tac(tac_list, create_tac(TAC_IF_NE, left_tac->arg1, left_tac->arg2, label_true));
            else if (node->left->type == NODE_LT) tac_list = concat_tac(tac_list, create_tac(TAC_IF_LT, left_tac->arg1, left_tac->arg2, label_true));
            else if (node->left->type == NODE_GT) tac_list = concat_tac(tac_list, create_tac(TAC_IF_GT, left_tac->arg1, left_tac->arg2, label_true));
            else if (node->left->type == NODE_LE) tac_list = concat_tac(tac_list, create_tac(TAC_IF_LE, left_tac->arg1, left_tac->arg2, label_true));
            else if (node->left->type == NODE_GE) tac_list = concat_tac(tac_list, create_tac(TAC_IF_GE, left_tac->arg1, left_tac->arg2, label_true));
            else { // Se a condição for uma expressão simples, verificar se é diferente de zero
                tac_list = concat_tac(tac_list, create_tac(TAC_IF_NE, left_tac->result, "0", label_true));
            }
            tac_list = concat_tac(tac_list, create_tac(TAC_GOTO, NULL, NULL, label_next));
            tac_list = concat_tac(tac_list, create_tac(TAC_LABEL, NULL, NULL, label_true));
            tac_list = concat_tac(tac_list, middle_tac);
            tac_list = concat_tac(tac_list, create_tac(TAC_LABEL, NULL, NULL, label_next));
            break;
        case NODE_IF_ELSE:
            label_true = new_label();
            label_false = new_label();
            label_next = new_label();
            left_tac = generate_tac(node->left); // Condição
            middle_tac = generate_tac(node->middle); // Bloco IF
            right_tac = generate_tac(node->right); // Bloco ELSE

            tac_list = left_tac;
            // Adicionar TAC condicional
            if (node->left->type == NODE_EQ) tac_list = concat_tac(tac_list, create_tac(TAC_IF_EQ, left_tac->arg1, left_tac->arg2, label_true));
            else if (node->left->type == NODE_NE) tac_list = concat_tac(tac_list, create_tac(TAC_IF_NE, left_tac->arg1, left_tac->arg2, label_true));
            else if (node->left->type == NODE_LT) tac_list = concat_tac(tac_list, create_tac(TAC_IF_LT, left_tac->arg1, left_tac->arg2, label_true));
            else if (node->left->type == NODE_GT) tac_list = concat_tac(tac_list, create_tac(TAC_IF_GT, left_tac->arg1, left_tac->arg2, label_true));
            else if (node->left->type == NODE_LE) tac_list = concat_tac(tac_list, create_tac(TAC_IF_LE, left_tac->arg1, left_tac->arg2, label_true));
            else if (node->left->type == NODE_GE) tac_list = concat_tac(tac_list, create_tac(TAC_IF_GE, left_tac->arg1, left_tac->arg2, label_true));
            else { // Se a condição for uma expressão simples, verificar se é diferente de zero
                tac_list = concat_tac(tac_list, create_tac(TAC_IF_NE, left_tac->result, "0", label_true));
            }
            tac_list = concat_tac(tac_list, create_tac(TAC_GOTO, NULL, NULL, label_false));
            tac_list = concat_tac(tac_list, create_tac(TAC_LABEL, NULL, NULL, label_true));
            tac_list = concat_tac(tac_list, middle_tac);
            tac_list = concat_tac(tac_list, create_tac(TAC_GOTO, NULL, NULL, label_next));
            tac_list = concat_tac(tac_list, create_tac(TAC_LABEL, NULL, NULL, label_false));
            tac_list = concat_tac(tac_list, right_tac);
            tac_list = concat_tac(tac_list, create_tac(TAC_LABEL, NULL, NULL, label_next));
            break;
        case NODE_WHILE:
            label_true = new_label(); // Rótulo para o início do loop (condição)
            label_next = new_label(); // Rótulo para depois do loop
            label_false = new_label(); // Rótulo para o corpo do loop

            left_tac = generate_tac(node->left); // Condição
            right_tac = generate_tac(node->right); // Bloco WHILE

            tac_list = create_tac(TAC_LABEL, NULL, NULL, label_true); // Início do loop
            tac_list = concat_tac(tac_list, left_tac);
            // Adicionar TAC condicional
            if (node->left->type == NODE_EQ) tac_list = concat_tac(tac_list, create_tac(TAC_IF_EQ, left_tac->arg1, left_tac->arg2, label_false));
            else if (node->left->type == NODE_NE) tac_list = concat_tac(tac_list, create_tac(TAC_IF_NE, left_tac->arg1, left_tac->arg2, label_false));
            else if (node->left->type == NODE_LT) tac_list = concat_tac(tac_list, create_tac(TAC_IF_LT, left_tac->arg1, left_tac->arg2, label_false));
            else if (node->left->type == NODE_GT) tac_list = concat_tac(tac_list, create_tac(TAC_IF_GT, left_tac->arg1, left_tac->arg2, label_false));
            else if (node->left->type == NODE_LE) tac_list = concat_tac(tac_list, create_tac(TAC_IF_LE, left_tac->arg1, left_tac->arg2, label_false));
            else if (node->left->type == NODE_GE) tac_list = concat_tac(tac_list, create_tac(TAC_IF_GE, left_tac->arg1, left_tac->arg2, label_false));
            else { // Se a condição for uma expressão simples, verificar se é diferente de zero
                tac_list = concat_tac(tac_list, create_tac(TAC_IF_NE, left_tac->result, "0", label_false));
            }
            tac_list = concat_tac(tac_list, create_tac(TAC_GOTO, NULL, NULL, label_next)); // Se a condição for falsa, sai do loop
            tac_list = concat_tac(tac_list, create_tac(TAC_LABEL, NULL, NULL, label_false)); // Corpo do loop
            tac_list = concat_tac(tac_list, right_tac);
            tac_list = concat_tac(tac_list, create_tac(TAC_GOTO, NULL, NULL, label_true)); // Volta para a condição
            tac_list = concat_tac(tac_list, create_tac(TAC_LABEL, NULL, NULL, label_next)); // Depois do loop
            break;
        case NODE_RETURN:
            right_tac = generate_tac(node->left); // Expressão de retorno
            temp_result = right_tac ? right_tac->result : node->left->value; // Se for um número ou ID direto
            tac_list = concat_tac(right_tac, create_tac(TAC_RETURN, NULL, NULL, temp_result));
            break;
        case NODE_PRINT:
            right_tac = generate_tac(node->left); // Expressão a ser impressa
            temp_result = right_tac ? right_tac->result : node->left->value; // Se for um número ou ID direto
            tac_list = concat_tac(right_tac, create_tac(TAC_PRINT, NULL, NULL, temp_result));
            break;
        default:
            // Para outros nós, apenas concatena o TAC dos filhos
            left_tac = generate_tac(node->left);
            right_tac = generate_tac(node->right);
            middle_tac = generate_tac(node->middle);
            next_tac = generate_tac(node->next);
            tac_list = concat_tac(left_tac, right_tac);
            tac_list = concat_tac(tac_list, middle_tac);
            tac_list = concat_tac(tac_list, next_tac);
            break;
    }
    return tac_list;
}