# Visão Geral da ABI e Geração de Código

Este documento explica a implementação do gerador de código e as decisões de design para gerar assembly x86-64 em macOS ARM.

## Decisão de Arquitetura Alvo

**Plataforma de Desenvolvimento:** macOS em Apple Silicon (ARM64 M4)  
**Plataforma Alvo:** Assembly x86-64  
**Execução:** Camada de emulação Rosetta 2

### Por que Ter x86-64 como Alvo em Hardware ARM?

Este compilador gera assembly x86-64 mesmo rodando em hardware ARM. A razão principal é que a biblioteca de macros `abi.asm` já estava escrita para x86-64, fornecendo abstrações de alto nível para convenções de chamada. Reescrever isso para ARM64 exigiria um conjunto de instruções completamente diferente.

O x86-64 também oferece um caminho de implementação mais simples, com convenções de chamada bem documentadas e excelente suporte a macros do NASM. Do ponto de vista educacional, é a arquitetura assembly mais comumente ensinada, com recursos abundantes de aprendizado e comparação direta com compiladores padrão como GCC e Clang.

### Requisitos de Implementação

Para tornar o código x86-64 executável em ARM Mac, a implementação precisou gerar sintaxe NASM válida, criar um símbolo `_start` para o linker, integrar macros `abi.asm` para convenções de chamada, usar syscalls específicas do macOS (0x2000001 para exit) e ter como alvo o formato `macho64` com flags de versão de plataforma corretas.


## O Sistema de Macros ABI

O arquivo `src/abi.asm` fornece macros que abstraem padrões comuns de assembly x86-64, funcionando como uma biblioteca padrão para assembly. O sistema inclui construções para funções, retornos, escopos, convenções de chamada, blocos de código, condicionais e alocação de dados.

Ao usar essas macros, a configuração e desmontagem do stack frame acontecem automaticamente. A macro `function` se expande para o prólogo padrão `push rbp` e `mov rbp, rsp`, enquanto `return` trata do epílogo `leave` e `ret`, garantindo convenções de chamada consistentes sem gerenciamento manual.

## Implementação do Gerador de Código

O gerador de código em `src/codegen.c` traduz a AST em assembly usando uma abordagem híbrida. Elementos estruturais como definições de função usam macros ABI para convenções adequadas, enquanto a lógica do programa usa instruções x86-64 cruas para variáveis, expressões e fluxo de controle.

Este design fornece abstração de macros para limites de função e convenções de chamada, mantendo controle total sobre a lógica central. Variáveis são alocadas com `sub rsp, 8`, expressões usam instruções de CPU como `mov` e `add`, e o fluxo de controle usa labels e jumps como `jz` e `jmp`.

### Gerenciamento de Variáveis

Variáveis são rastreadas usando offsets a partir do ponteiro de frame. Quando o gerador encontra `int x;`, ele aloca 8 bytes com `sub rsp, 8` e registra o offset. A atribuição carrega o valor em `rax` e o armazena no offset rastreado com `mov [rbp - 8], rax`.

O layout da pilha coloca o ponteiro de frame na base, com cada variável em um offset fixo abaixo dele: primeira em `rbp-8`, segunda em `rbp-16`, e assim por diante.

### Exemplo de Função Completa

Uma função C simples com variável, atribuição e retorno se traduz em assembly onde a macro `function main` trata do prólogo, instruções cruas gerenciam alocação e atribuição, e a macro `return` trata do epílogo.

**Assembly Gerado:**
```nasm
%include "src/abi.asm"

function main              ← Macro ABI (trata do prólogo)
    sub rsp, 8            ← Assembly cru (variável)
    mov rax, 10           ← Assembly cru (expressão)
    mov [rbp - 8], rax    ← Assembly cru (atribuição)
    mov rax, 0            ← Assembly cru (valor de retorno)
    add rsp, 8            ← Assembly cru (limpeza)
    return                ← Macro ABI (trata do epílogo)
end                       ← Macro ABI (fecha escopo)
```

### Implementação do Ponto de Entrada

Todo arquivo assembly gerado inclui um ponto de entrada `_start` para tornar o executável inicializável. O gerador de código cria isso após emitir o código do usuário, estabelecendo-o como um símbolo global na seção de texto. Ele usa a macro `execute` da ABI para chamar main, depois invoca a syscall de exit do macOS (0x2000001) para terminar limpo.

Isso é necessário porque o linker do macOS espera `_start` ao linkar com `-e _start`. A macro `execute` garante convenções de chamada adequadas, e a syscall de exit explícita garante terminação limpa.

## Detalhes de Implementação

### Criando o Ponto de Entrada

O gerador de código produz um executável inicializável gerando `_start` na função `generate_code`. Após gerar as funções do usuário, ele emite a declaração global, diretiva de seção e label de entrada. A função usa `execute` para chamar main, depois configura a syscall de exit com o número específico do macOS 0x2000001.

```c
// Em generate_code()
fprintf(out, "\nglobal _start\n");
fprintf(out, "section .text\n");
fprintf(out, "_start:\n");
fprintf(out, "    execute main\n");
fprintf(out, "    mov rax, 0x2000001\n");  // syscall sys_exit do macOS
fprintf(out, "    xor rdi, rdi\n");
fprintf(out, "    syscall\n");
```

### Envolvendo Funções com Macros ABI

Funções são envolvidas usando macros abi.asm para garantir código de prólogo e epílogo adequados. O gerador emite a macro function com o nome, gera o corpo e fecha com a macro end. Isso fornece configuração automática de stack frame, rastreamento de escopo e tratamento adequado do epílogo.

```c
fprintf(out, "\nfunction %s\n", name);
// ... gera corpo da função ...
fprintf(out, "end\n");
```

### Gerenciamento de Variáveis na Pilha

Variáveis são alocadas manualmente na pilha em vez de usar macros array da ABI. A implementação incrementa o offset da pilha, registra a variável em uma tabela de consulta e emite uma instrução de alocação de pilha com um comentário. Esta abordagem é mais simples para variáveis locais, dá controle total sobre o layout e facilita a depuração com offsets explícitos.

```c
stack_offset += 8;
add_var(name, stack_offset);
fprintf(out, "    sub rsp, 8  ; %s\n", name);
```

### Compilando para macOS x86-64

O Makefile usa flags específicas para compilação cross-architecture. O NASM recebe `-f macho64` para gerar arquivos objeto x86-64 do macOS. O linker usa `-platform_version macos 11.0 15.0` para compatibilidade com Rosetta 2, `-e _start` para o ponto de entrada e `-static` para um executável estaticamente linkado.

```makefile
nasm -f macho64 output.asm -o output.o
ld -static -platform_version macos 11.0 15.0 -e _start -o executable output.o
```

## Compilando e Executando

Gere assembly com `./compiler tests/examples/test_simple.c`, monte com `nasm -f macho64 tests/examples/test_simple.c.asm -o build/test_simple.o`, depois linke e execute com `ld -static build/test_simple.o -o build/test_simple -platform_version macos 11.0 15.0 -e _start` seguido de `./build/test_simple`.

## Resumo

O pipeline analisa código-fonte C para gerar uma AST, percorre a árvore emitindo assembly NASM (usando macros abi.asm para estrutura, x86-64 cru para lógica), monta para código objeto x86-64, linka o executável e o executa através da tradução Rosetta 2 no ARM Mac.

Esta abordagem híbrida fornece limites de função limpos via macros mantendo controle direto sobre a lógica do programa, resultando em assembly fácil de entender e debugar com execução perfeita através do Rosetta 2.
