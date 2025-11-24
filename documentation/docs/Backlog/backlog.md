# Estrutura do Backlog

Foi decidido em grupo que o Backlog terá a seguinte estrutura: **Épico → Feature → User Story → Tasks**, sendo que os **Épicos** representam cada **fase de um Compilador**, e que vão se decompondo em subtarefas (Feature, US's e Task). As User Stories e as Tasks são escritas de forma granular e com linguagem acessível para que todos do time sejam capazes de entender cada tarefa e realizá-las com eficiência.

## Épicos

### Épico A -  Análise Léxica

**Feature A.1: Implementador do Scanner (Flex)** — Status: Feito.

- **US-01:** Reconhecer palavras-chave (if, else, while, for, return, struct, typedef, etc.) — Statu - Tasks:
 1. Listar palavras-chave alvo e inserir em arquivo de tokens.
 2. Escrever regras Flex para cada palavra-chave.
 3. Adicionar teste unitário que valida reconhecimento de cada palavra-chave.

- **US-02:** Reconhecer identificadores, literais numéricos e caracteres — Status: Feito.
 - Tasks:
 1. Implementar expressão regular para identificadores (letra + alfanum/_).
 2. Implementar regex para literais (inteiros decimais, hex se necessário).
 3. Criar testes unitários cobrindo casos válidos/inválidos.

- **US-03:** Detectar e reportar erros léxicos — Status: Feito (básico).
 - Tasks:
 1. Implementar token `<INVALID>` que captura símbolos inválidos.
 2. Produzir mensagem de erro com linha/coluna.
 3. Adicionar teste que assegura erro léxico esperado em input malformado.

- **US-04:** Testes automatizados do léxico — Status: Feito (framework presente).
 - Tasks:
 1. Integrar testes de léxico no pipeline de testes.
 2. Cobrir tokens críticos com casos positivos/negativos.
 3. Criar fixture para carregar pequenos arquivos-sample.

### Épico B — Análise Sintática

**Feature B.1: Gramática de Estruturas de Controle (Bison)** — Status: Parcial/Feito (básico).

- **US-05:** Suporte a `if` / `else` — Status: Feito.
 - Tasks:
 1. Adicionar regras Bison para `if`/`else` com produção única e com `elif` suportado via else-ifencadeado.
 2. Testar casos com aninhamento e ausência de `else`.

- **US-06:** Suporte a loops (`while`, `for`) — Status: A Fazer.
 - Tasks:
 1. Escrever gramática para `while` (condição e bloco).
 2. Escrever gramática para `for` (inicialização; condição; passo; bloco).
 3. Testes que verifiquem saltos e escopos internos.

- **US-07:** Suporte a `goto` / `label` — Status: Feito.
 - Tasks:
 1. Mapear token `LABEL` e `GOTO` na gramática.
 2. Criar pass semântica que resolve labels (flag de resolução tardia).
 3. Testes de jump intra-função inválos (ex.: goto para label fora da função -> erro).

- **US-08:** Funções (declaração e corpo) — Status: Em Andamento / A Fazer.
 - Tasks:
 1. Definir produção para `function_definition` (tipo retorn, id, params, body).
 2. Implementar parsing de lista de parâmetros (possibilidade vazia).
 3. Testes de definição e chamadas simples.

- **US-09:** Construção da AST — Status: Feito (parcial).
 - Tasks:
 1. Definir estrutura de nós AST (Node type, children, token info).
 2. Alterar ações Bison para criar nós AST em vez de prints temporários.
 3. Serializar AST em formato textual para debug (ex.: S-expr).

- **US-10:** Testes do parser / mensagens de erro sintático — Status: Feito/Em Andamento.
 - Tasks:
 1. Implementar harness de teste para rodar parser em inputs e comparar AST.
 2. Melhorar mensagens de erro com sugestão de recuperação (panic mode simples).
 3. Cobrir casos sintáticos inválidos no suite.

### Épico C — Análise Semântica

**Feature C.1: Tabela de Símbolos e Escopagem** — Status: Em Andamento.

- **US-11:** Implementar tabela de símbolos (escopos: global, função, estrutura).
 - Tasks:
 1. Criar structs C para `Symbol` e `SymbolTable` com encadeamento de escopos.
 2. Implementar `enter_scope()` / `exit_scope()` nas ações semânticas do parser.
 3. Testes de lookup que confirmem visibilidade e sombra (shadowing).

- **US-12:** Resolução de labels por escopo — Status: A Fazer.
 - Tasks:
 1. Registrar labels na tabela de symbols com info de função.
 2. Ao final da função, verificar labels referenciados mas não definidos → erro.
 3. Testes que provoquem erro de label externo.

- **US-13:** Verificação de tipos (compatibilidade) — Status: A Fazer.
 - Tasks:
 1. Definir representação de tipos básicos (void, int, char, pointer).
 2. Implementar verificação em atribuições e retorno de função.
 3. Criar mensagens de erro com local e causa.

- **US-14:** Suporte a variáveis (estática, automática, registrador, imediata) — Status: Em Andament - Tasks (por tipo):
 - Estático:
 1. Implementar armazenamento simbólico e geração de label global.
 2. Teste: variável estática inicializada.
 - Automática (stack):
 1. Definir layout de stack-frame (offset por variável).
 2. Código de alocação/desalocação no prólogo/epílogo de função.
 3. Teste: funções recursivas simples com variáveis locais.
 - Registrador:
 1. Marcar variáveis elegíveis para alocação em registrador (heurística simples).
 2. Tests: atribuição e leitura em registrador vs stack.
 - Imediata:
 1. Suportar constantes inline em expressões e propagação simples.

- **US-15:** Ponteiros e endereçamento (`&`, `*`) — Status: A Fazer.
 - Tasks:
 1. Adicionar tipos ponteiro na representação de tipos.
 2. Implementar semântica de `&` para variáveis l-values.
 3. Tests para leitura/escrita via ponteiro.

**Feature C.2: Verificação de chamadas de função (arg count / types)** — Status: A Fazer.

- **US-16:** Checar número e tipos de argumentos — Status: A Fazer.
 - Tasks:
 1. Registrar assinatura de função na tabela de símbolos.
 2. Ao encontrar chamada, comparar tipos e número → emitir warning/erro.
 3. Tests: chamada com menos/mais argumentos e tipos incompatíveis.

### Épico D — Geração de Código Intermediário (IR)

**Feature D.1: Definição e Estrutura do IR** — Status: A Fazer.

- **US-17:** Escolher representação (three-address code) — Status: A Fazer.
 - Tasks:
 1. Especificar formato textual para IR (op, dst, src1, src2).
 2. Implementar estruturas C para instruções IR.
 3. Criar utilitário `emit_ir(op, dst, src1, src2)`.

- **US-18:** Gerar IR para expressões aritméticas — Status: A Fazer.
 - Tasks:
 1. Implementar visitor que percorre AST de expressão e emite IR.
 2. Tests: expressão com parênteses e precedência.

- **US-19:** Gerar IR para controle de fluxo — Status: A Fazer.
 - Tasks:
 1. Emissão de labels IR (L1, L2...) e saltos condicionais.
 2. Mapear `if/else` e `while` para sequência de labels e jumps.
 3. Tests end-to-end que compilam trecho e chequem IR esperado.

- **US-20:** IR para funções (prólogo/epílogo) — Status: A Fazer.
 - Tasks:
 1. Definir convenção de chamada simples (salvar rbp, ajustar rsp etc.)
 2. Gerar IR para passagem de parâmetros (por stack/registros simples).
 3. Testes com chamadas aninhadas.

### Épico E — Otimização (Opcional)

**Feature E.1: Otimizações Locais** — Status: A Fazer.

- **US-21:** Constant folding — Status: A Fazer.
 - Tasks:
 1. Implementar passe que detecta operações com operandos constantes e substitui por constante co 2. Tests: (2+3)*4 => 20 no IR.

- **US-22:** Dead code elimination (local) — Status: A Fazer.
 - Tasks:
 1. Detectar instruções sem uso (def sem uso) e remover.
 2. Tests que assegurem semântica preservada.

### Épico F — Geração de Código Final (Assembly x86)

**Feature F.1: Gerador Assembly x86 (texto)** — Status: Em Andamento (parcial).

- **US-23:** Gerar assembly para expressões aritméticas — Status: Em Andamento.
 - Tasks:
 1. Mapear IR aritmético para instruções x86 (add, sub, imul, idiv).
 2. Implementar gerador simples de alocação temporária (stack spill quando necessário).
 3. Tests: compilar expressão e montar com `as`/`ld` (manual check).

- **US-24:** Gerar assembly para controle de fluxo (if/else, loops) — Status: A Fazer.
 - Tasks:
 1. Gerar labels e jumps cond/unc.
 2. Assegurar que labels IR → labels ASM 1:1.
 3. Tests: trecho com if-else e loop.

- **US-25:** Prólogo/Epílogo de função — Status: A Fazer.
 - Tasks:
 1. Emitir padrão de função (push rbp; mov rbp, rsp; sub rsp, N).
 2. Restaurar registros no epílogo e `ret`.
 3. Tests com função que retorna valor int.

- **US-26:** Gerenciar registradores vs pilha — Status: A Fazer.
 - Tasks:
 1. Implementar alocador de registros linear-scan simples (heurística).
 2. Spill para stack quando necessário.
 3. Tests com uso de muitos temporários.

- **US-27:** Supporte a inserção de assembly inline — Status: A Fazer.
 - Tasks:
 1. Permitir token INLINE_ASM incorporado na AST e copiado para output.
 2. Validar contexto (apenas dentro de funções).
 3. Testes unitários que preservem bloco inline.
