# Notepad3 Plus — abas, editores divididos e memória de sessão

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg?style=flat-square)](https://opensource.org/licenses/BSD-3-Clause)
![Platform](https://img.shields.io/badge/Windows-x64-0a7bbb?style=flat-square)
![Native](https://img.shields.io/badge/nativo-C%2FWin32-444?style=flat-square)
![RAM](https://img.shields.io/badge/RAM-~50%20MB-2e9b3e?style=flat-square)

Editor de texto **leve, nativo e portátil** para Windows, baseado no
[Notepad3](https://github.com/rizonesoft/Notepad3) (Scintilla), com **abas**,
**divisão de editores estilo Visual Studio** e um modo **"bloco de notas que
lembra sozinho"**. Para quem quer a praticidade de abas/painéis de uma IDE
**sem o peso** de um editor baseado em Electron.

> 🇧🇷 Português abaixo · 🇺🇸 [English version below](#-english)

| Abas | Editores divididos (split) |
|------|----------------------------|
| ![Abas](docs/img/abas.png) | ![Split](docs/img/split.png) |

---

## 🇧🇷 Português

### O que é
Um *fork* do Notepad3 que transforma o editor de **documento único** em um
ambiente de **múltiplas abas e painéis divididos**, mantendo o consumo de
recursos de um aplicativo nativo minúsculo.

### Destaques
- **Abas** — vários arquivos abertos ao mesmo tempo; cada arquivo é uma aba, com
  destaque de sintaxe, *code folding* e codificação por arquivo.
- **Divisão de editores (split)** — divida a área em painéis lado a lado ou
  empilhados; **cada painel é um editor independente e ativo**.
- **Arrastar e grudar (dock estilo VS)** — arraste uma aba: solte **no centro** de
  um painel para movê-la; solte **numa borda** para criar uma divisão naquele lado
  (com prévia translúcida do destino).
- **Bloco de notas que lembra sozinho** — ao fechar, faz *backup* de **tudo** que
  estava aberto (inclusive não-salvos, sem título e vazios) e **reabre na próxima
  vez com a mesma organização** de painéis. Sem perguntas, sem perder nada.
- **Nomear sem salvar** — dê um nome de exibição a qualquer aba, mesmo sem gravar
  em disco; o nome é lembrado.
- **Várias abas em branco** e comando **"Apagar tudo e fechar editores"**.
- **Um único executável portátil** — o `Notepad3.exe` (link estático) embarca o
  `minipath.exe` e o extrai sozinho quando preciso. Sem instalador e sem o
  *Visual C++ Redistributable*.

### Vantagens sobre um VS Code (para edição simples)
Para abrir, editar e salvar arquivos do dia a dia, um editor nativo entrega a
mesma comodidade de abas/painéis gastando uma fração dos recursos:

| | **Notepad3 Plus** | VS Code (típico) |
|---|---|---|
| Memória (RAM) | **~50 MB** | ~300–700 MB |
| Tamanho | **1 arquivo `.exe` (~6 MB)** | instalação de ~350 MB+ |
| Tecnologia | **nativo C / Win32** | Electron (Chromium + Node) |
| Início | **instantâneo** | segundos |
| Instalação | **nenhuma** (portátil) | instalador |
| Dependências | **nenhuma** (link estático) | runtime do Electron |
| Processos | **1** | vários (Chromium) |

> Não é um substituto de IDE: é a opção certa quando você quer **abas + split
> rápidos e leves** para textos, código pequeno, anotações e configs.

### Como usar
A maioria das ações está no **menu de contexto da aba** (botão direito sobre uma
aba): Nova aba · Renomear aba · Fechar aba/outras · Dividir →/↓ · Fechar painel ·
Apagar tudo.

| Ação | Como |
|------|------|
| Nova aba | `Ctrl+N` · duplo-clique na área vazia da barra |
| Próxima / anterior | `Ctrl+PageDown` / `Ctrl+PageUp` |
| Fechar aba | clique do **meio** na aba · menu de contexto |
| Reordenar | arrastar a aba na barra |
| Mover / dividir | arrastar a aba para outro painel ou borda |
| Redimensionar painéis | arrastar o divisor |

### Onde os dados são salvos
A sessão (abas, conteúdo não salvo e layout) fica no **perfil do usuário**:
`%LOCALAPPDATA%\Rizonesoft\Notepad3\Session\`. Assim o executável é totalmente
**portátil** e pode rodar até de um local somente-leitura.

### Download e build
- **Download:** baixe o `Notepad3.exe` mais recente na aba **Releases**. É um único
  arquivo — basta executar.
- **Compilar:** Visual Studio 2022 (Build Tools) com C++ e Windows SDK.
  ```bat
  powershell -ExecutionPolicy Bypass -File Version.ps1
  msbuild Notepad3.sln /m /p:Configuration=Release /p:Platform=x64
  powershell -ExecutionPolicy Bypass -File Build\embed_minipath.ps1
  ```
  Saída: `Bin\Release_x64_v143\Notepad3.exe`.

### Créditos
- **Ideia, conceito e direção:** **Rodrigo**
- **Implementação (co-autor):** **Claude Opus 4.8 (1M context)** — Anthropic
- **Base:** [Notepad3](https://github.com/rizonesoft/Notepad3) © Rizonesoft, licença
  BSD-3-Clause (preservada).

Veja [MELHORIAS.md](MELHORIAS.md) para detalhes e [CHANGELOG.md](CHANGELOG.md) para
o histórico de alterações.

---

## 🇺🇸 English

A **lightweight, native, portable** Windows text editor based on
[Notepad3](https://github.com/rizonesoft/Notepad3) (Scintilla), adding **tabs**,
**Visual-Studio-style split editors** and a **"notepad that remembers itself"**
mode. The convenience of an IDE's tabs/panes **without the weight** of an
Electron-based editor.

### Highlights
- **Tabs** — many files open at once; each is a tab with syntax highlighting, code
  folding and per-file encoding.
- **Split editors** — split the area into side-by-side or stacked panes; **each
  pane is an independent, live editor**.
- **Drag & dock (VS-style)** — drag a tab and drop it in a pane's **center** to
  move it, or on an **edge** to create a split there (with a translucent preview).
- **Notepad that remembers itself** — on close it backs up **everything** open
  (including unsaved/untitled/empty) and **reopens it next time with the same pane
  layout**. No prompts, nothing lost.
- **Name a tab without saving**, create **multiple blank tabs**, and a **"Wipe all
  & close editors"** command.
- **One portable executable** — the statically-linked `Notepad3.exe` embeds
  `minipath.exe` and self-extracts it on demand. No installer, no Visual C++
  Redistributable.

### Why over VS Code (for simple editing)

| | **Notepad3 Plus** | VS Code (typical) |
|---|---|---|
| Memory (RAM) | **~50 MB** | ~300–700 MB |
| Size | **1 `.exe` (~6 MB)** | ~350 MB+ install |
| Tech | **native C / Win32** | Electron (Chromium + Node) |
| Startup | **instant** | seconds |
| Install | **none** (portable) | installer |
| Dependencies | **none** (static link) | Electron runtime |
| Processes | **1** | many (Chromium) |

> Not an IDE replacement — it's the right tool when you want **fast, light tabs +
> split** for text, small code, notes and config files.

### Usage
Most actions are in the **tab context menu** (right-click a tab): New tab · Rename
tab · Close tab/others · Split →/↓ · Close pane · Wipe all. Shortcuts: `Ctrl+N`
new tab (or double-click the empty strip), `Ctrl+PageUp/Down` to switch,
middle-click to close, drag a tab to reorder/move/split.

### Data location
The session (tabs, unsaved content, layout) is stored in the user profile at
`%LOCALAPPDATA%\Rizonesoft\Notepad3\Session\`, so the executable stays fully
portable.

### Download & build
Grab the latest `Notepad3.exe` from **Releases** (single file). To build: Visual
Studio 2022 Build Tools (C++ + Windows SDK), then
`msbuild Notepad3.sln /p:Configuration=Release /p:Platform=x64` followed by
`Build\embed_minipath.ps1`.

### Credits
- **Idea, concept & direction:** **Rodrigo**
- **Implementation (co-author):** **Claude Opus 4.8 (1M context)** — Anthropic
- **Base:** [Notepad3](https://github.com/rizonesoft/Notepad3) © Rizonesoft,
  BSD-3-Clause (preserved).
