# Aureliani

Projeto desenvolvido para a disciplina de **Compiladores 1** da Universidade de Brasília (UnB).  
Implementa um compilador para uma **linguagem C-like customizada**, utilizando **Flex** e **Bison** para análise léxica e sintática, e gerando código **assembly compatível com NASM** por meio de um sistema de **macros semânticas**.

---

## Visão Geral

Este compilador traduz programas escritos em uma sintaxe inspirada na linguagem C — mas adaptada com extensões específicas — diretamente para **assembly NASM**. Em vez de construir uma AST ou código intermediário, ele gera chamadas a **macros semânticas** definidas em `semantical.asm`, que simulam recursos de alto nível como:

- Estruturas (`struct`)
- Arrays com tamanho dinâmico
- Funções com escopo
- Atribuições condicionais (ex: `assign_if_less_than`)
- Controle de fluxo (`if`, `else`, `label`, `goto`)
- Inclusão de código assembly inline

O projeto segue a abordagem de **front-end direto**, onde a análise sintática já produz código de saída, delegando a verificação semântica e o gerenciamento de escopo ao pré-processador do NASM.

- **Professor:** Sergio Antônio Andrade de Freitas  
- **Disciplina:** Compiladores 1 – Universidade de Brasília (UnB)  
- **Equipe:** 13

---

## Equipe

<div align="center">
 <p><strong>Contribuidores do Aureliani</strong></p>
 <table>
   <tr>
     <td align="center">
       <a href="https://github.com/algorithmorphic">
         <img style="border-radius: 20%; border: 3px solid #1f2328;" src="https://avatars.githubusercontent.com/u/72679483?v=4" width="160px" height="160px" alt=""/>
         <br /><sub><b>Artur Ricardo</b></sub>
       </a><br />
     </td>
     <td align="center">
       <a href="https://github.com/fillipeb50">
         <img style="border-radius: 20%; border: 3px solid #1f2328;" src="https://avatars.githubusercontent.com/u/72557022?v=4" width="160px" height="160px" alt=""/>
         <br /><sub><b>Fillipe Andrade</b></sub>
       </a><br />
     </td>
     <td align="center">
       <a href="https://github.com/LuGit00">
         <img style="border-radius: 20%; border: 3px solid #1f2328;" src="https://avatars.githubusercontent.com/u/166548910?v=4" width="160px" height="160px" alt=""/>
         <br /><sub><b>Luciano Machado</b></sub>
       </a><br />
     </td>
     <td align="center">
       <a href="https://github.com/RufinoVfR">
         <img style="border-radius: 20%; border: 3px solid #1f2328;" src="https://avatars.githubusercontent.com/u/144750571?v=4" width="160px" height="160px" alt=""/>
         <br /><sub><b>Vinícius Rufino</b></sub>
       </a><br />
     </td>
     <td align="center">
       <a href="https://github.com/yanzin00">
         <img style="border-radius: 20%; border: 3px solid #1f2328;" src="https://avatars.githubusercontent.com/u/118907920?v=4" width="160px" height="160px" alt=""/>
         <br /><sub><b>Yan Lucas</b></sub>
       </a><br />
     </td>
   </tr>
 </table>
</div>

---

## Estrutura do Projeto


```
.
├── COMPILER_USAGE.md # Instruções detalhadas de uso e sintaxe da linguagem
├── CONTRIBUTING.md # Diretrizes para contribuição
├── documentation/ # Documentos de apoio (C, NASM, teoria de compiladores)
│ ├── ansi-iso-9899-1990-1.pdf # Padrão oficial da linguagem C
│ ├── nasmdoc.pdf # Manual do NASM
│ ├── teoria.txt # Notas teóricas da equipe
│ └── docs/ # Documentação gerada com MkDocs (site estático)
├── LICENSE # Licença do projeto (GPL-3.0)
├── Makefile # Automatiza build, execução e limpeza
├── README.md
├── src/
│ ├── lexical.l # Analisador léxico (Flex)
│ ├── syntactical.y # Gramática e ações semânticas (Bison)
│ └── semantical.asm # Macros NASM que implementam a semântica da linguagem
└── tests/
└── example0.txt # Exemplo funcional de programa de entrada
```

## Fases do Compilador

Nosso compilador adota uma arquitetura simplificada, focada em **geração direta de código** sem representações intermediárias. As fases implementadas são:

1. **Análise Léxica**  
   Realizada com **Flex**, identifica tokens como palavras-chave (`function`, `struct`, `if`), operadores (`=`, `+=`, `<?`), identificadores, números e strings.

2. **Análise Sintática**  
   Implementada com **Bison**, valida a estrutura gramatical da linguagem e, **durante o parsing**, já **gera diretamente instruções em assembly** compatíveis com o NASM.

3. **Geração de Código Final**  
   Não há AST, TAC ou código intermediário. As ações semânticas no parser escrevem diretamente no arquivo de saída chamadas a **macros NASM** (ex: `assign x, y`, `struct Pair`, `end instance`).

4. **Análise Semântica (implícita no back-end)**  
   Regras de escopo, herança, tamanho de structs e resolução de identificadores são **implementadas nas macros de `semantical.asm`**, não no front-end. O NASM realiza essas verificações durante o pré-processamento e montagem.

> **Não implementado:**  
> - Árvore Sintática Abstrata (AST)  
> - Código intermediário (TAC, IR)  
> - Otimização de código  
> - Verificação explícita de tipos ou escopo no front-end

Essa abordagem permite um compilador **leve e rápido**, ideal para demonstrar conceitos de parsing e integração com assembly, delegando complexidade semântica ao back-end em NASM.

## Como Rodar o Compilador

Para compilar e executar o compilador, siga os passos abaixo:

### 1. Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas em seu sistema:

-   **GCC (GNU Compiler Collection):** Para compilar o código C.
-   **Flex:** Gerador de analisadores léxicos.
-   **Bison:** Gerador de analisadores sintáticos.

Em sistemas baseados em Debian/Ubuntu, você pode instalá-los com:

```bash
sudo apt-get update
sudo apt-get install -y build-essential flex bison
```

### 2. Compilação do Projeto

Navegue até a raiz do projeto e execute o comando `make`:

```bash
make
```

Este comando irá:

1. Gerar `syntactical.tab.c` e `syntactical.tab.h` a partir de `src/syntactical.y` (usando Bison).
2. Gerar `lexical.yy.c` a partir de `src/lexical.l` (usando Flex).
3. Compilar os arquivos gerados e criar o executável `compiler` na raiz do projeto.
4. Se a compilação for bem-sucedida, o executável `compiler` estará disponível diretamente na pasta raiz.

### 3. Execução do Compilador

Para compilar um programa escrito na linguagem aceita pelo compilador, execute:

```bash
./compiler <caminho_para_arquivo_fonte>
```

Por exemplo, para testar com o exemplo fornecido::

```bash
./compiler tests/example0.txt
```

O compilador irá:

- Realizar a análise léxica e sintática do arquivo de entrada;
- Gerar um arquivo de saída com extensão .asm (ex: tests/example0.asm);
- Incluir automaticamente src/semantical.asm no início do arquivo gerado;
- Invocar o NASM para montar o código em um arquivo objeto (.o).

Se houver erros de sintaxe, o compilador exibirá uma mensagem clara com o número da linha e o token problemático. Caso contrário, o código será montado com sucesso pelo NASM.

### 4. Limpeza do Projeto

Para remover os arquivos gerados pela compilação (executável, objetos, arquivos gerados por Flex/Bison), execute:

```bash
make clean
```

## Como Contribuir

Consulte o arquivo [`CONTRIBUTING.md`](https://github.com/LuGit00/CompilerDisciplineAssignment?tab=contributing-ov-file) para obter informações sobre como configurar o ambiente de desenvolvimento, submeter alterações e seguir as convenções de código.

## Licença

Este projeto está licenciado sob a `GNU General Public License v3.0`. Consulte o arquivo [`LICENSE`](https://github.com/LuGit00/CompilerDisciplineAssignment?tab=GPL-3.0-1-ov-file) para mais detalhes.