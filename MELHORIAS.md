# Notepad3 — Edição com Abas e Editores Divididos (estilo Visual Studio)

Este é um *fork* do [Notepad3](https://github.com/rizonesoft/Notepad3) (licença BSD‑3,
© Rizonesoft) com um conjunto de melhorias que transformam o editor de **documento
único** em um ambiente de **múltiplas abas e painéis divididos**, no estilo do
Microsoft Visual Studio, além de um modo "bloco de notas que lembra sozinho".

---

## Autoria

- **Ideia, conceito e direção de produto:** **Rodrigo**
  Concebeu toda a visão do recurso e conduziu o desenvolvimento de ponta a ponta,
  definindo *o que* construir e *como* deveria se comportar:
  - abas para abrir vários arquivos;
  - **divisão de editores (split)** com painéis vivos lado a lado / empilhados;
  - **arrastar e "grudar" abas** entre painéis com o mouse (dock estilo VS);
  - comportamento de **"bloco de notas que lembra sozinho"** (salvar e restaurar
    automaticamente tudo o que estava aberto, inclusive não‑salvos);
  - **restaurar com a mesma organização** dos painéis;
  - poder **criar várias abas em branco** e **dar nome a um editor sem salvar**;
  - comando para **apagar todos os dados e fechar os editores**;
  - **binário portátil** (link estático) e dados de sessão na **pasta do usuário**.
  Também validou cada etapa e direcionou os ajustes.

- **Implementação (co‑autor):** **Claude Opus 4.8 (1M context)** — Anthropic
  Análise da arquitetura, projeto técnico e escrita do código C/Win32 que realiza
  as funcionalidades acima sobre o Scintilla.

---

## Resumo das melhorias

| Área | O que mudou |
|------|-------------|
| **Abas** | Vários documentos abertos como abas; cada arquivo aberto vira uma aba. |
| **Split de painéis** | Área de edição dividida em painéis vivos (horizontal/vertical) numa árvore com divisores arrastáveis; **cada painel é um editor Scintilla independente e ativo ao mesmo tempo**. |
| **Arrastar e grudar (dock)** | Arrastar uma aba com o mouse e soltar **no centro** de um painel a move para lá; soltar **numa borda** cria uma divisão naquele lado (com prévia translúcida do destino). |
| **Memória de sessão** | Ao fechar, faz *backup* automático de **todos** os editores (incluindo não‑salvos, sem título e vazios) e **reabre tudo** ao iniciar — sem perguntar. |
| **Mesma organização** | A **disposição dos painéis** (a árvore de divisões e proporções) é salva e recriada na reabertura. |
| **Nomear sem salvar** | É possível dar um **nome de exibição** a qualquer aba, mesmo sem salvar em disco; o nome é lembrado entre sessões. |
| **Várias abas em branco** | "Nova aba" cria sempre uma aba vazia nova, sem precisar digitar nada. |
| **Apagar tudo** | Comando para **fechar todos os editores e apagar os dados lembrados** da sessão. |
| **Portabilidade** | Executável com **link estático** (não precisa do Visual C++ Redistributable). |
| **Local dos dados** | A sessão é salva na **pasta do usuário** (`%LOCALAPPDATA%\Rizonesoft\Notepad3\Session`), não na pasta do binário. |

---

## Detalhes

### Abas (múltiplos documentos)
Cada aba mantém seu próprio documento do Scintilla e todo o estado por‑arquivo
(caminho, codificação, fim de linha, *lexer*, posição do cursor, *bookmarks*).
A troca de aba preserva e restaura esse estado. Um marcador **●** indica abas com
alterações não salvas.

### Editores divididos (split)
A área de edição é uma **árvore de painéis**. Cada painel tem sua própria barra de
abas e um editor vivo. Os comandos:

- **Dividir → (lado a lado)** / **Dividir ↓ (empilhado)**
- **Fechar painel**

O painel em foco passa a ser o "ativo": título, barra de status e todos os comandos
(localizar, salvar, etc.) operam sobre ele. Os divisores entre painéis podem ser
**arrastados** para redimensionar.

### Arrastar e grudar abas (estilo Visual Studio)
Arraste uma aba com o mouse:
- soltando **no meio** de um painel → a aba **se move** para aquele painel;
- soltando **numa borda** (esquerda/direita/topo/baixo) → cria uma **divisão** e
  encaixa a aba ali;
- soltando **na própria barra de abas** → apenas **reordena**.

Durante o arraste, uma **prévia azul translúcida** mostra onde a aba vai encaixar.
Se o painel de origem ficar vazio, ele é fechado e o layout se reorganiza.

### "Bloco de notas que lembra sozinho"
Ao fechar o aplicativo, ele **não pergunta** se quer salvar: faz *backup* do conteúdo
de **cada editor** (inclusive os sem título e os não salvos) e, na próxima abertura,
**restaura tudo** exatamente como estava — com a mesma organização de painéis e a aba
ativa. Funciona como um bloco de notas que nunca perde o que você estava fazendo.

> Se a pasta de sessão não puder ser gravada, o app volta a perguntar sobre salvar,
> para nunca perder dados silenciosamente.

### Nomear um editor sem salvar
Pelo menu de contexto da aba → **Renomear aba**: digite um nome de exibição. Útil para
rascunhos sem título. O nome aparece na aba e é lembrado entre sessões.

### Apagar tudo
Menu de contexto da aba → **Apagar tudo e fechar editores** (com confirmação): fecha
todos os painéis/abas e remove os dados de sessão lembrados.

---

## Como usar

A maioria das ações está no **menu de contexto da aba** (clique com o botão direito
sobre uma aba):

- Nova aba · Renomear aba
- Fechar aba · Fechar as outras
- Dividir → · Dividir ↓ · Fechar painel
- Apagar tudo e fechar editores

Atalhos e gestos:

| Ação | Como |
|------|------|
| Nova aba | `Ctrl+N` · duplo‑clique na área vazia da barra de abas |
| Próxima / aba anterior | `Ctrl+PageDown` / `Ctrl+PageUp` |
| Fechar aba | clique do **meio** sobre a aba · menu de contexto |
| Reordenar abas | arrastar a aba dentro da barra |
| Mover/dividir | arrastar a aba para outro painel ou para uma borda |
| Redimensionar painéis | arrastar o divisor entre eles |

---

## Onde os dados são salvos

- **Sessão (abas, conteúdo não salvo, layout):**
  `%LOCALAPPDATA%\Rizonesoft\Notepad3\Session\`
  (arquivos `session.ini` e `tab*.bak`).
- **Configurações (`Notepad3.ini`):** segue o modelo do Notepad3 (portátil, ao lado do
  executável, ou redirecionado por usuário).

Como a sessão fica no **perfil do usuário**, o executável pode ser **movido livremente**
e até rodar de um local somente‑leitura (ex.: `Program Files`).

---

## Binário (Release) para download

O executável é compilado em **Release x64 com link estático** (`/MT`), ou seja, é
**portátil**: não exige o *Visual C++ Redistributable*. Ele depende apenas de DLLs do
próprio Windows.

- Arquivo gerado: `Bin\Release_x64_v143\Notepad3.exe`
- Para distribuir: anexe o `.exe` (ou um `.zip` com o `.exe` + DLLs de idioma, se
  desejar) a uma **Release** do GitHub (aba *Releases* → *Draft a new release*).

### Compilar do código
Pré‑requisitos: Visual Studio 2022 (Build Tools) com o workload C++ e Windows SDK.

```bat
:: gerar o cabeçalho de versão
powershell -ExecutionPolicy Bypass -File Version.ps1
:: compilar (link estático já configurado no Release)
msbuild Notepad3.sln /m /p:Configuration=Release /p:Platform=x64
```

Saída: `Bin\Release_x64_v143\Notepad3.exe`.

---

## Créditos e licença

Baseado no **Notepad3** © Rizonesoft, distribuído sob a licença **BSD‑3‑Clause**.
Este fork preserva a licença original. As melhorias descritas aqui foram idealizadas e
dirigidas por **Rodrigo** e implementadas com **Claude Opus 4.8 (1M context)** como
co‑autor.
