# Changelog

Histórico de alterações do **Notepad3 Plus** (fork do Notepad3).
Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/).
Cada alteração feita ao longo do tempo é registrada aqui.

## [Não lançado]

### 2026-06-25

#### Adicionado
- **Abas (multi-documento):** vários arquivos abertos como abas; cada aba mantém
  seu próprio documento Scintilla e estado por-arquivo (caminho, codificação, EOL,
  lexer, cursor, bookmarks). Marcador ● para alterações não salvas.
- **Divisão de editores (split):** árvore de painéis horizontais/verticais com
  divisores arrastáveis; cada painel é um editor Scintilla vivo e independente.
  Indireção de "painel ativo" reaproveita todo o código existente.
- **Arrastar e grudar (dock estilo VS):** arrastar uma aba e soltar no centro de um
  painel a move; soltar numa borda cria um split naquele lado, com prévia
  translúcida do destino.
- **Memória de sessão ("lembra sozinho"):** ao fechar, faz backup de todos os
  editores (incluindo não-salvos, sem título e vazios) e reabre tudo na próxima
  inicialização, **com a mesma organização de painéis** (layout dos splits).
- **Renomear aba sem salvar:** nome de exibição para qualquer aba (inclusive sem
  título), lembrado entre sessões.
- **Várias abas em branco:** "Nova aba" sempre cria uma aba vazia nova; duplo-clique
  na área vazia da barra também cria.
- **Apagar tudo:** comando para fechar todos os editores e apagar os dados de sessão.
- **Distribuição em executável único:** o `Notepad3.exe` (link estático) embarca o
  `minipath.exe` como resource (via `Build\embed_minipath.ps1`) e o extrai sozinho
  em `%LOCALAPPDATA%` quando necessário.
- Menu de contexto da aba com todas as ações; clique do meio fecha aba; reordenar
  arrastando; `Ctrl+PageUp/PageDown` para navegar; re-tematização dos painéis ao
  trocar o tema.
- Documentação: `README.md` (PT+EN) com prints e comparativo com o VS Code,
  `MELHORIAS.md`, `LICENSE` (BSD-3) e este `CHANGELOG.md`.

#### Alterado
- **Local da sessão:** passou da pasta do executável para o **perfil do usuário**
  (`%LOCALAPPDATA%\Rizonesoft\Notepad3\Session\`), tornando o binário totalmente
  portátil e utilizável de locais somente-leitura.
- Fechar o aplicativo não pergunta mais sobre salvar quando a memória de sessão
  está ativa (faz backup automático; só pergunta se o local não for gravável).

#### Corrigido
- Restauração de sessão preservando o conteúdo correto em cada painel
  (`SetActivePane` reaponta o handle do Scintilla mesmo quando o painel já é o
  ativo, evitando escrever no editor errado após um split).
- Detecção de codificação ao restaurar arquivos salvos (não força mais
  `SkipUnicodeDetect`, que corrompia a exibição de arquivos UTF-8).
- Remoção de abas em branco sobrando ao recriar o layout de painéis.

---

> Notas: baseado no [Notepad3](https://github.com/rizonesoft/Notepad3) © Rizonesoft
> (BSD-3-Clause). Ideia e direção: Rodrigo. Implementação: Claude Opus 4.8 (co-autor).
