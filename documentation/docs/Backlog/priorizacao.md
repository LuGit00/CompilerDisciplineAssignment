# Priorização do Backlog

A priorização do backlog foi feita com base nos seguintes critérios:

- **Urgência para funcionalidade mínima**
- **Dependência entre épicos**
- **Facilidade de implementação (baixa complexidade)**
- **Importância para a compilação correta**

### Etapas Prioritárias

1. **Análise Léxica e Sintática**
   - Base para construir qualquer verificação posterior.
   - Implementado inicialmente com Flex e Bison.

2. **Análise Semântica**
   - Fundamental para detectar erros e garantir integridade de escopos e tipos.

3. **Geração de Código Intermediário**
   - Conectada diretamente à representação da AST.

4. **Geração de Assembly**
   - Última etapa funcional do compilador.

5. **Otimizações (Opcional)**
   - Executadas somente se houver tempo e estabilidade no pipeline completo.

### Estratégia de Execução

Foi utilizado o modelo "vertical slicing", garantindo que a cada sprint o compilador pudesse evoluir com um fluxo completo de entrada e saída, mesmo que parcial.