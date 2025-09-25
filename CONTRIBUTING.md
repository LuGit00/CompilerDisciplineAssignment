# Guia de Contribuição

Bem-vindo ao projeto! Agradecemos seu interesse em contribuir. Para garantir um fluxo de trabalho eficiente e consistente, por favor, siga as diretrizes abaixo.

## 1. Configuração do Ambiente de Desenvolvimento

Para começar a contribuir, você precisará configurar seu ambiente com as ferramentas necessárias.

### 1.1. Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas em seu sistema operacional:

-   **GCC (GNU Compiler Collection):** O compilador C padrão. Versão 9.x ou superior é recomendada.
-   **Flex:** Uma ferramenta para gerar analisadores léxicos (scanners). Versão 2.6.x ou superior.
-   **Bison:** Uma ferramenta para gerar analisadores sintáticos (parsers). Versão 3.x ou superior.
-   **Git:** Sistema de controle de versão para gerenciar o código-fonte.

#### Instalação no Ubuntu/Debian

Abra um terminal e execute os seguintes comandos:

```bash
sudo apt-get update
sudo apt-get install -y build-essential flex bison git
```

#### Instalação em Outros Sistemas Operacionais

-   **macOS:** Você pode instalar GCC, Flex, Bison e Git usando Homebrew:
    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install gcc flex bison git
    ```
-   **Windows:** Recomenda-se usar o [WSL (Windows Subsystem for Linux)](https://docs.microsoft.com/pt-br/windows/wsl/install) para ter um ambiente Linux completo, ou instalar o [MinGW](http://www.mingw.org/) para GCC, e as versões para Windows de Flex e Bison (disponíveis em seus respectivos sites).

### 1.2. Clonar o Repositório

Após instalar os pré-requisitos, clone o repositório do projeto para sua máquina local:

```bash
git clone https://github.com/LuGit00/CompilerDisciplineAssignment
cd CompilerDisciplineAssignment
```

### 1.3. Compilação Inicial

Navegue até o diretório `src/` e compile o projeto. Isso garantirá que seu ambiente está configurado corretamente e que o compilador base funciona.

```bash
cd src/
make
```

Se tudo estiver correto, um executável chamado `compiler` será criado no diretório `src/`.

## 2. Fluxo de Trabalho (Git/GitHub)

Utilizamos um fluxo de trabalho baseado em branches para gerenciar as contribuições, garantindo que o código principal (`main`) permaneça estável.

### 2.1. Crie uma Branch para sua Feature/Correção

Antes de começar a trabalhar em uma nova funcionalidade ou correção de bug, crie uma nova branch a partir da branch `main`:

```bash
git checkout main
git pull origin main # Garante que sua branch main está atualizada
git checkout -b feature/nome-da-sua-feature # Use 'bugfix/' para correções de bugs
```

**Exemplos de nomes de branch:**
-   `feature/implementa-analise-semantica`
-   `bugfix/corrige-erro-lexico-comentarios`
-   `feature/adiciona-laco-for`

### 2.2. Faça Suas Alterações

Implemente suas alterações no código. Lembre-se de:

-   **Commits Pequenos e Atômicos:** Cada commit deve resolver um único problema ou adicionar uma única funcionalidade, tornando o histórico de alterações mais fácil de entender e reverter, se necessário.
-   **Mensagens de Commit Claras:** Escreva mensagens de commit descritivas que expliquem *o quê* e *por que* a alteração foi feita. Use o imperativo (ex: 


Adiciona, Corrige, Implementa).

### 2.3. Teste Suas Alterações

Antes de submeter suas alterações, certifique-se de que elas não introduzem novos bugs e que todos os testes existentes (e novos testes que você possa ter adicionado para sua funcionalidade) passam. Você pode compilar e testar o compilador localmente:

```bash
cd ../src # Se você estiver em outro diretório
make clean && make
./compiler ../tests/examples/seu_novo_teste.c
```

### 2.4. Sincronize com a Branch Principal

Antes de abrir um Pull Request, é uma boa prática atualizar sua branch com as últimas alterações da branch `main` para evitar conflitos:

```bash
git checkout feature/nome-da-sua-feature
git pull origin main
```

Resolva quaisquer conflitos de merge que possam surgir. Se houver muitos conflitos, pode ser útil usar `git rebase main` em vez de `git pull origin main` para manter um histórico de commits mais limpo, mas isso requer mais cuidado.

### 2.5. Abra um Pull Request (PR)

Quando suas alterações estiverem prontas para revisão, envie sua branch para o GitHub e abra um Pull Request para a branch `main`.

-   **Título do PR:** Deve ser conciso e descritivo (ex: `feat: Implementa análise semântica básica` ou `fix: Corrige erro de sintaxe em declarações`).
-   **Descrição do PR:** Forneça uma descrição clara e detalhada do que foi feito, por que foi feito, quais problemas resolve e como foi testado. Inclua capturas de tela ou exemplos de saída, se aplicável.
-   **Referencie Issues:** Se o seu PR resolver uma issue existente, referencie-a na descrição (ex: `Closes #123` ou `Fixes #456`).
-   **Revisores:** Peça a outros membros da equipe para revisar seu código.

### 2.6. Revisão de Código

Sua contribuição será revisada por outros membros da equipe. Esteja aberto a feedback e faça as alterações solicitadas. O processo de revisão de código é uma oportunidade para aprender e melhorar a qualidade do código.

## 3. Convenções de Código

Para manter a consistência e a legibilidade do código, siga as seguintes convenções:

-   **Estilo de Código:** Adotaremos um estilo de código baseado no [K&R (Kernighan & Ritchie)](https://en.wikipedia.org/wiki/K%26R_C), com algumas adaptações para modernidade e legibilidade. Use `clang-format` ou uma ferramenta similar para formatar seu código automaticamente. Exemplo:
    ```c
    // Exemplo de estilo K&R
    int main(int argc, char *argv[])
    {
        if (argc > 1) {
            // Bloco de código
        } else {
            // Outro bloco
        }
        return 0;
    }
    ```
-   **Nomenclatura:**
    -   **Variáveis e Funções:** Use `snake_case` (ex: `minha_variavel`, `minha_funcao`).
    -   **Constantes e Macros:** Use `UPPER_SNAKE_CASE` (ex: `MAX_SIZE`, `NODE_TYPE_INT`).
    -   **Tipos (`typedef`):** Use `PascalCase` ou `CamelCase` (ex: `ASTNode`, `SymbolTable`).
-   **Comentários:** Comente seu código onde for necessário para explicar lógicas complexas, decisões importantes ou partes não óbvias. Use comentários de linha (`//`) para explicações curtas e comentários de bloco (`/* ... */`) para descrições mais longas ou documentação de funções.
-   **Indentação:** Use 4 espaços para indentação, não tabs.

## 4. Relato de Bugs e Sugestões

Se você encontrar um bug ou tiver uma sugestão de melhoria, por favor, abra uma [Issue no GitHub](https://docs.github.com/pt/issues/tracking-your-work-with-issues/creating-an-issue) do projeto. Ao abrir uma issue:

-   **Para Bugs:**
    -   Forneça um título claro e conciso.
    -   Descreva os passos para reproduzir o bug.
    -   Indique o comportamento esperado e o comportamento observado.
    -   Inclua mensagens de erro, logs ou capturas de tela, se houver.
    -   Mencione a versão do compilador e do sistema operacional.
-   **Para Sugestões de Funcionalidades:**
    -   Descreva a funcionalidade proposta e seu propósito.
    -   Explique como ela beneficiaria o projeto.
    -   Forneça exemplos de uso, se possível.

---