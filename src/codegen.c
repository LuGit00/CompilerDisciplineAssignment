#include "codegen.h"
#include "semantic/symbol_table.h"
#include <stdlib.h>
#include <string.h>

static int label_count = 0;
static int stack_offset = 0;
static int func_has_return = 0;

typedef struct VarInfo {
  char *name;
  int offset;
  struct VarInfo *next;
} VarInfo;

static VarInfo *vars = NULL;

static void add_var(const char *name, int offset) {
  VarInfo *v = malloc(sizeof(VarInfo));
  v->name = strdup(name);
  v->offset = offset;
  v->next = vars;
  vars = v;
}

static int get_var_offset(const char *name) {
  for (VarInfo *v = vars; v; v = v->next) {
    if (strcmp(v->name, name) == 0)
      return v->offset;
  }
  return -1;
}

static void clear_vars() {
  while (vars) {
    VarInfo *tmp = vars;
    vars = vars->next;
    free(tmp->name);
    free(tmp);
  }
  stack_offset = 0;
}

static void gen_expr(ASTNode *n, FILE *out);
static void gen_stmt(ASTNode *n, FILE *out);

static void gen_expr(ASTNode *n, FILE *out) {
  if (!n)
    return;

  switch (n->type) {
  case NODE_NUMBER:
    fprintf(out, "    mov rax, %s\n", n->value);
    break;

  case NODE_ID: {
    int off = get_var_offset(n->value);
    if (off != -1) {
      fprintf(out, "    mov rax, [rbp - %d]\n", off);
    } else {
      fprintf(out, "    mov rax, 0  ; var %s not found\n", n->value);
    }
    break;
  }

  case NODE_ADD:
    gen_expr(n->left, out);
    fprintf(out, "    push rax\n");
    gen_expr(n->right, out);
    fprintf(out, "    pop rbx\n");
    fprintf(out, "    add rax, rbx\n");
    break;

  case NODE_SUB:
    gen_expr(n->left, out);
    fprintf(out, "    push rax\n");
    gen_expr(n->right, out);
    fprintf(out, "    mov rbx, rax\n");
    fprintf(out, "    pop rax\n");
    fprintf(out, "    sub rax, rbx\n");
    break;

  case NODE_MUL:
    gen_expr(n->left, out);
    fprintf(out, "    push rax\n");
    gen_expr(n->right, out);
    fprintf(out, "    pop rbx\n");
    fprintf(out, "    imul rax, rbx\n");
    break;

  case NODE_DIV:
    gen_expr(n->left, out);
    fprintf(out, "    push rax\n");
    gen_expr(n->right, out);
    fprintf(out, "    mov rbx, rax\n");
    fprintf(out, "    pop rax\n");
    fprintf(out, "    xor rdx, rdx\n");
    fprintf(out, "    idiv rbx\n");
    break;

  default:
    fprintf(out, "    mov rax, 0\n");
    break;
  }
}

static void gen_cmp(ASTNode *n, FILE *out) {
  if (!n)
    return;
  gen_expr(n->left, out);
  fprintf(out, "    push rax\n");
  gen_expr(n->right, out);
  fprintf(out, "    pop rbx\n");
  fprintf(out, "    cmp rbx, rax\n");
}

static void gen_stmt(ASTNode *n, FILE *out) {
  if (!n)
    return;

  switch (n->type) {
  case NODE_DECLARATION:
    stack_offset += 8;
    add_var(n->right->value, stack_offset);
    fprintf(out, "    sub rsp, 8  ; %s\n", n->right->value);
    break;

  case NODE_ASSIGNMENT:
    gen_expr(n->right, out);
    {
      int off = get_var_offset(n->left->value);
      if (off != -1) {
        fprintf(out, "    mov [rbp - %d], rax\n", off);
      }
    }
    break;

  case NODE_IF: {
    int lbl = label_count++;
    gen_cmp(n->left, out);
    fprintf(out, "    jz .L%d\n", lbl);
    gen_stmt(n->right, out);
    fprintf(out, ".L%d:\n", lbl);
    break;
  }

  case NODE_IF_ELSE: {
    int else_lbl = label_count++;
    int end_lbl = label_count++;
    gen_cmp(n->left, out);
    fprintf(out, "    jz .L%d\n", else_lbl);
    gen_stmt(n->middle, out);
    fprintf(out, "    jmp .L%d\n", end_lbl);
    fprintf(out, ".L%d:\n", else_lbl);
    gen_stmt(n->right, out);
    fprintf(out, ".L%d:\n", end_lbl);
    break;
  }

  case NODE_WHILE: {
    int start = label_count++;
    int end = label_count++;
    fprintf(out, ".L%d:\n", start);
    gen_cmp(n->left, out);
    fprintf(out, "    jz .L%d\n", end);
    gen_stmt(n->right, out);
    fprintf(out, "    jmp .L%d\n", start);
    fprintf(out, ".L%d:\n", end);
    break;
  }

  case NODE_RETURN:
    if (n->left)
      gen_expr(n->left, out);
    fprintf(out, "    add rsp, %d\n", stack_offset);
    fprintf(out, "    return\n");
    func_has_return = 1;
    break;

  case NODE_PRINT:
    if (n->left)
      gen_expr(n->left, out);
    break;

  case NODE_STATEMENT_LIST:
    if (n->left)
      gen_stmt(n->left, out);
    if (n->right)
      gen_stmt(n->right, out);
    break;

  default:
    break;
  }
}

static void gen_function(ASTNode *n, FILE *out) {
  if (!n || n->type != NODE_FUNCTION_DEFINITION)
    return;

  char *name = n->right ? n->right->value : "main";
  fprintf(out, "\nfunction %s\n", name);

  clear_vars();
  func_has_return = 0;

  if (n->middle)
    gen_stmt(n->middle, out);

  if (!func_has_return) {
    fprintf(out, "    add rsp, %d\n", stack_offset);
    fprintf(out, "    return\n");
  }
  fprintf(out, "end\n");
}

void generate_code(ASTNode *root, FILE *out) {
  if (!root || !out)
    return;

  fprintf(out, "%%include \"src/abi.asm\"\n\n");

  if (root->type == NODE_FUNCTION_DEFINITION) {
    gen_function(root, out);
  } else if (root->type == NODE_PROGRAM) {
    gen_function(root, out);
  }

  fprintf(out, "\nglobal _start\n");
  fprintf(out, "section .text\n");
  fprintf(out, "_start:\n");
  fprintf(out, "    execute main\n");
  fprintf(out, "    mov rax, 0x2000001\n");
  fprintf(out, "    xor rdi, rdi\n");
  fprintf(out, "    syscall\n");

  clear_vars();
}
