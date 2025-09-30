# Guia de Uso do Compilador

## Visão Geral
Este documento fornece instruções sobre como compilar e executar o projeto de compilador C localizado no diretório `/src`.

## Pré-requisitos

Você precisa ter as seguintes ferramentas instaladas em seu sistema:
- **GCC (GNU Compiler Collection)**
- **Flex (Fast Lexical Analyzer)**
- **Bison (GNU Parser Generator)**

No macOS, você pode instalá-las via Homebrew:
```bash
brew install gcc flex bison
```

## Instruções de Compilação

### 1. Navegue até o Diretório de Origem
```bash
cd CompilerDisciplineAssignment/src
```

### 2. Compile o Projeto
```bash
make
```

Se você encontrar problemas com a flag `-Wcounterexamples` (não suportada em versões mais antigas do Bison), o Makefile foi modificado para remover esta flag. Execute:
```bash
make clean
make
```

Isso fará:
- Gerar `parser.tab.c` e `parser.tab.h` a partir de `parser.y` usando o Bison
- Gerar `lex.yy.c` a partir de `scanner.l` usando o Flex
- Compilar todos os arquivos-fonte e vinculá-los para criar o executável `compiler`

## Executando o Compilador

### Uso Básico
```bash
./compiler <caminho_para_arquivo_entrada>
```

### Exemplos
```bash
# Executar no exemplo de programa válido fornecido
./compiler ../tests/examples/valid_program.c

# Executar em um arquivo personalizado
./compiler meu_programa.c
```

### Executando Testes Integrados
```bash
make test
```

## Capacidades Atuais

O compilador atualmente suporta:
- Definições de função (`int main() {...}`)
- Declarações de variáveis (`int x;`, `float y;`)
- Atribuições de variáveis (`x = 10;`)
- Expressões aritméticas (`x = x + y;`, `x = x - y;`, `x = x * y;`, `x = x / y;`)
- Expressões relacionais (`x > y`, `x < y`, `x >= y`, etc.)
- Instruções de controle de fluxo (`if/else`, loops `while`)
- Instruções de retorno (`return x;`)
- Blocos aninhados e escopos
- Gerenciamento de tabela de símbolos para verificação de tipo

## Limitações Atuais

O compilador NÃO suporta atualmente:
- Declaração com inicialização imediata (ex: `int x = 10;`) - você deve usar declaração e atribuição separadas
- Conversão de tipos (ex: `(int)y`)
- Análise de expressões complexas que envolvem inicialização imediata

### Exemplo de Código Funcional
```c
int main() {
    int x;      // declaração
    x = 10;     // atribuição
    int y;
    y = 20;
    x = x + y;
    if (x > 15) {
        x = x - 5;
    } else {
        x = 0;
    }
    while (x < 10) {
        x = x + 1;
    }
    return x;
}
```

## Informações de Saída

Quando um arquivo é analisado com sucesso, o compilador mostrará:
1. **Tabela de Símbolos**: Mostra as variáveis e seus tipos em diferentes escopos
2. **Árvore Sintática Abstrata (AST)**: Mostra a estrutura analisada do programa
3. **Código de Três Endereços (TAC)**: Mostra a representação intermediária

## Solução de Problemas

### Problemas Comuns:
- **"library 'fl' not found"**: Isso foi resolvido removendo a flag `-lfl` do Makefile
- **"invalid option -- W"**: Isso foi resolvido removendo a flag `-Wcounterexamples` do Makefile
- **"call to undeclared function 'yyparse'"**: Isso foi resolvido adicionando a declaração da função em main.c

### Se a Compilação Falhar:
1. Limpe o projeto: `make clean`
2. Reconstrua: `make`
3. Se ainda tiver problemas, verifique se todas as ferramentas necessárias (gcc, flex, bison) estão instaladas

## Estrutura do Projeto
- `lexer/`: Contém as definições do analisador léxico
- `parser/`: Contém as definições de gramática e parser
- `semantic/`: Contém implementações de AST e tabela de símbolos
- `ir_generator/`: Contém o gerador de TAC (Código de Três Endereços)
- `main.c`: Ponto de entrada do compilador
- `Makefile`: Instruções de compilação