# CompilerDisciplineAssignment
Projeto de uma implementação de um compilador feito com flex e yacc para uma disciplina de universidade de compiladores.
# Compilador C - Projeto da Disciplina Compiladores 1

## Visão Geral do Projeto

Este repositório contém o projeto de um compilador para uma sublinguagem de C, desenvolvido como parte da disciplina de Compiladores 1 da Universidade de Brasília - UnB. O objetivo principal é aplicar os conceitos teóricos e práticos de construção de compiladores, desde a análise léxica até a geração de código, utilizando a metodologia Problem Based Learning (PBL) e o framework Scrum para o gerenciamento do projeto.

- **Professor:** Sergio Antônio Andrade de Freitas
- **Contato do Professor:** sergiofreitas@unb.br
- **GitHub do Professor:** https://github.com/sergioaafreitas

## Equipe

A nossa equipe é atualmente identificada pelo número **13**, mediante divisão/organização realizada pelo professor da disciplina.

<div align="center">
 <p><strong>Tabela 1 – Membros da Equipe</strong></p>
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
         <img style="border-radius: 20%; border: 3px solid #1f2328 ;" src="https://avatars.githubusercontent.com/u/144750571?v=4" width="160px" height="160px" alt=""/>
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

## Objetivo do Compilador

Nosso compilador será capaz de traduzir código-fonte escrito em uma sublinguagem de C para [especificar a linguagem alvo, ex: código de máquina, assembly, ou código intermediário específico]. O foco será na implementação das fases essenciais de um compilador, garantindo a correção e a robustez do processo de tradução.

## Estrutura do Repositório

```
.
├── README.md                 # Visão geral do projeto, equipe, objetivos e marcos.
├── CONTRIBUTING.md           # Guia para novos contribuidores e fluxo de trabalho.
├── LICENSE                   # Informações sobre a licença do projeto.
├── docs/                     # Documentação detalhada do projeto.
│   ├── PROJECT_STRUCTURE.md  # Este documento.
│   ├── DECISION_LOG.md       # Registro de decisões técnicas importantes.
│   ├── SPRINT_PLANNING.md    # Detalhamento do planejamento das sprints.
│   ├── GLOSSARY.md           # Glossário de termos técnicos.
│   ├── IMPROVEMENT_GUIDE.md  # Guia para melhorias e novas funcionalidades.
│   └── DISCIPLINE_EXPLANATION.md # Explicação didática da disciplina.
├── src/                      # Código-fonte do compilador.
│   ├── lexer/                # Arquivos relacionados à análise léxica (Flex).
│   │   └── scanner.l         # Definições de tokens e regras léxicas.
│   ├── parser/               # Arquivos relacionados à análise sintática (Bison).
│   │   └── parser.y          # Definições da gramática e ações semânticas.
│   ├── semantic/             # Arquivos para análise semântica.
│   │   ├── symbol_table.h    # Definição da tabela de símbolos.
│   │   ├── symbol_table.c    # Implementação da tabela de símbolos.
│   │   ├── ast.h             # Definição da Árvore Sintática Abstrata (AST).
│   │   └── ast.c             # Implementação da AST e funções de manipulação.
│   ├── ir_generator/         # Arquivos para geração de código intermediário.
│   │   └── ir_generator.c    # Lógica para traduzir AST para código intermediário.
│   ├── code_generator/       # Arquivos para geração de código final.
│   │   └── code_generator.c  # Lógica para traduzir código intermediário para a linguagem alvo.
│   ├── main.c                # Ponto de entrada principal do compilador.
│   └── Makefile              # Script para compilação do projeto.
└── tests/                    # Testes e exemplos de código.
   ├── unit_tests/           # Testes de unidade para módulos específicos.
   ├── integration_tests/    # Testes de integração para o compilador completo.
   └── examples/             # Exemplos de código-fonte na sublinguagem C.
```

## Fases do Compilador

O desenvolvimento do compilador seguirá as fases clássicas:

1.  **Análise Léxica:** Identificação e classificação de tokens (palavras-chave, identificadores, operadores, etc.).
2.  **Análise Sintática:** Verificação da estrutura gramatical do código-fonte e construção da Árvore Sintática Abstrata (AST).
3.  **Análise Semântica:** Verificação de tipos, escopo de variáveis e outras regras de significado da linguagem.
4.  **Geração de Código Intermediário:** Tradução da AST para uma representação mais próxima do código de máquina.
5.  **Otimização de Código (Opcional):** Melhorias no código intermediário para aumentar a eficiência.
6.  **Geração de Código Final:** Tradução do código intermediário para a linguagem alvo (ex: Assembly).

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

Navegue até o diretório `src/` do projeto e execute o comando `make`:

```bash
cd src/
make
```

Este comando irá:

1.  Gerar `parser.tab.c` e `parser.tab.h` a partir de `parser/parser.y` (usando Bison).
2.  Gerar `lex.yy.c` a partir de `lexer/scanner.l` (usando Flex).
3.  Compilar todos os arquivos `.c` e linká-los para criar o executável `compiler`.

Se a compilação for bem-sucedida, você verá o executável `compiler` no diretório `src/`.

### 3. Execução do Compilador

Para testar o compilador com um arquivo de código-fonte, execute-o da seguinte forma:

```bash
./compiler <caminho_para_arquivo_fonte>
```

Por exemplo, para testar com o programa de exemplo `valid_program.c`:

```bash
./compiler ../tests/examples/valid_program.c
```

O compilador irá processar o arquivo e, no estado atual, imprimirá a Árvore Sintática Abstrata (AST) se a análise léxica e sintática for bem-sucedida. Caso contrário, reportará erros de sintaxe.

### 4. Limpeza do Projeto

Para remover os arquivos gerados pela compilação (executável, objetos, arquivos gerados por Flex/Bison), execute:

```bash
make clean
```

## Marcos Importantes (Pontos de Controle)

-   **P1:** Avaliação inicial do projeto, incluindo a definição da linguagem, planejamento das sprints e o progresso das fases léxica e sintática inicial.
   -   **Período de Envio do Formulário:** 25/04/2025 a 28/04/2025
   -   **Apresentação:** [Data a ser definida pelo professor]

-   **P2:** Avaliação do progresso intermediário, com foco nas funcionalidades principais desenvolvidas, melhorias e ajustes no planejamento.
   -   **Período de Envio do Formulário:** 30/05/2025 a 02/06/2025
   -   **Apresentação:** [Data a ser definida pelo professor]

-   **Entrega Final e Entrevista:** Entrega do compilador completo e entrevista presencial com a equipe para demonstração e justificativa das decisões técnicas.
   -   **Entrega no GitHub:** [Data a ser definida pelo professor]
   -   **Entrevista:** [Data a ser definida pelo professor]

## Como Contribuir

Consulte o arquivo [`CONTRIBUTING.md`](https://github.com/LuGit00/CompilerDisciplineAssignment/blob/main/CONTRIBUTING.md) para obter informações sobre como configurar o ambiente de desenvolvimento, submeter alterações e seguir as convenções de código.

## Licença

Este projeto está licenciado sob a `GNU General Public License v3.0`. Consulte o arquivo [`LICENSE`](https://github.com/LuGit00/CompilerDisciplineAssignment/blob/main/LICENSE) para mais detalhes.