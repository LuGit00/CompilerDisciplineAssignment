# Backlog Priorizado

Abaixo, o backlog está estruturado por ordem de prioridade e agrupado por épico.

## Épico: Análise Léxica
- ✅ US01: Identificar palavras-chave
- ✅ US02: Reconhecer identificadores e literais
- ✅ US04: Utilizar Flex para escaneamento léxico
- ✅ US05: Detectar erros léxicos
- ✅ US07: Cobertura de testes de tokens

## Épico: Análise Sintática
- ✅ US09: Suporte a if e else
- ✅ US10: Suporte a goto e label
- ⏳ US11: Suporte a loops (while / for)
- ⏳ US12: Definição de funções
- ⏳ US13: Definição de variáveis
- ⏳ US14: Definir struct
- ⏳ US15: Modificadores de acesso
- ✅ US16: Gerar AST do programa
- ✅ US17: Cobertura de testes sintáticos
- ⏳ US18: Tratar erros sintáticos

## Épico: Análise Semântica
- ⏳ US19: Gerenciar escopos global/função/estrutura
- ⏳ US20: Resolução de rótulos por escopo
- ⏳ US21: Checar compatibilidade de tipos
- ⏳ US22–25: Variáveis com diferentes tipos de alocação
- ✅ US26: Atribuir valor imediato a variável
- ⏳ US27: Atribuir variável a variável
- ⏳ US28–29: Endereçamento e ponteiros
- ⏳ US30–31: Semântica de funções e structs
- ⏳ US32: Cobertura de testes semânticos

## Épico: Geração de Código Intermediário
- ⏳ US33–35: IR para expressões, controle e funções
- ⏳ Feature: Testes Automatizados de IR

## Épico: Geração de Código Final (Assembly x86)
- ⏳ US38: Código para expressões aritméticas
- ⏳ US39: Código para controle de fluxo
- ⏳ US40: Código para funções
- ✅ US41: Geração de chamadas de sistema
- ⏳ US43: Código para structs/classes
- ⏳ US44: Testes de Código Gerado

## Épico: Otimizações (Opcional)
- ⏳ US36: Constant Folding
- ⏳ US37: Remoção de código morto

✅ = Feito · ⏳ = A Fazer/Em Andamento