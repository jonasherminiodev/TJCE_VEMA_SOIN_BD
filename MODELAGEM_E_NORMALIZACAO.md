# MODELAGEM E NORMALIZAÇÃO — TJCE VEMA SOIN

Documentação técnica do modelo de dados do banco SQLite do projeto TJCE VEMA SOIN.

> **Legenda:**
> - ✅ **Implementado** — já está nos scripts do repositório.
> - 💡 **Recomendado** — melhoria proposta, ainda não aplicada.
> - ⚠️ **Pendência** — decisão que depende de confirmação da equipe.

---

## 1. Organização lógica do banco

O banco está dividido em três domínios funcionais:

```
┌─────────────────────────────────────────────────────────────────┐
│ DOMÍNIO 1 — DADOS DE PROCESSOS JUDICIAIS                       │
│   processo                                                      │
│   processo_movimentacao                                         │
├─────────────────────────────────────────────────────────────────┤
│ DOMÍNIO 2 — ANÁLISE E REFERÊNCIAS JURÍDICAS                    │
│   analise_ia_processo                                           │
│   norma                                                         │
│   processo_citacao_norma                                        │
├─────────────────────────────────────────────────────────────────┤
│ DOMÍNIO 3 — GESTÃO DE TAREFAS E PROVIDÊNCIAS                   │
│   servidor                                                      │
│   tag                                                           │
│   providencia_tipo                                              │
│   tarefa_servidor                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Função de cada tabela

### `processo`
Armazena a "capa" de cada processo judicial, com os dados retornados pela API do TJCE/PJe. Cada linha representa um processo único, identificado por `numeroProcesso`.

**Chave primária:** `numeroProcesso` (TEXT) — número oficial CNJ do processo, chave primária definitiva.
**Identificador externo:** `id_tjce` (TEXT) — identificador composto gerado pela aplicação no formato `TJCE_G1_<numeroProcesso>`.

### `processo_movimentacao`
Armazena cada ato/movimentação do histórico processual. Um processo pode ter dezenas ou centenas de movimentações.

**Chave principal:** `id` (INTEGER, autoincrement).
**Chave estrangeira:** `numeroProcesso` (TEXT) referenciando `processo(numeroProcesso)` com `ON DELETE CASCADE` — ✅ implementada.

### `analise_ia_processo`
Armazena o resultado da análise de inteligência artificial sobre cada processo: localidade textual ampla, campos de refinamento territorial (`municipio` para filtro macro, `bairro_regiao` para filtro micro), coordenadas geográficas (`latitude`, `longitude` como REAL), ecossistema afetado e resumo sintético do caso.

**Chave principal:** `id` (INTEGER, autoincrement).
**Chave estrangeira:** `numeroProcesso` (TEXT) referenciando `processo(numeroProcesso)` com `ON DELETE CASCADE` — ✅ implementada.
**Campos territoriais e geoespaciais:** `localidade` (TEXT), `municipio` (TEXT), `bairro_regiao` (TEXT), `latitude` (REAL), `longitude` (REAL).

#### Tabela de Referência Geoespacial (Mock — Ceará):
| Município (Macro) | Bairro / Região (Micro) | Latitude | Longitude |
|---|---|---|---|
| Fortaleza | Sabiaguaba | -3.798000 | -38.429000 |
| Fortaleza | Cocó | -3.748805 | -38.486371 |
| Fortaleza | Bacia do Maranguapinho / Bom Jardim | -3.785520 | -38.592540 |
| Fortaleza | Área Urbana Central | -3.719200 | -38.543100 |
| Caucaia | Aldeia Tapeba | -3.704000 | -38.695000 |
| Caucaia | Periferia / Distrito de Jurema | -3.756500 | -38.623270 |
| São Gonçalo do Amarante | Distrito Industrial do Pecém | -3.549780 | -38.814340 |
| Trairi | Flecheiras / Litoral Oeste | -3.220020 | -39.270120 |
| Baturité | Zona Serrana / Guaramiranga | -4.262500 | -38.932000 |
| Tauá | Sertão dos Inhamuns | -6.003060 | -40.292780 |
| Quixadá | Região dos Monólitos | -4.965500 | -39.010900 |
| Crato | Encosta da Chapada do Araripe | -7.234170 | -39.409440 |
| Sobral | Centro Histórico | -3.686100 | -40.349700 |
| Jaguaribara | Entorno do Castanhão | -5.757830 | -38.692600 |
| Aracati | Várzea do Rio Jaguaribe | -4.558300 | -37.767900 |
| Fortim | Estuário / Barra do Rio Pirangi | -4.385000 | -37.830000 |

### `norma`
Catálogo de normas jurídicas que podem ser citadas nos processos.

**Chave principal:** `id` (INTEGER, autoincrement).
**Restrição:** `nome UNIQUE NOT NULL`.

### `processo_citacao_norma`
Tabela de junção da relação N:N entre `processo` e `norma`.

**Chave primária composta:** `(numeroProcesso, norma_id)`.
**Chaves estrangeiras:** 
- `numeroProcesso` para `processo(numeroProcesso)` com `ON DELETE CASCADE` — ✅ implementada.
- `norma_id` para `norma(id)` com `ON DELETE CASCADE` — ✅ implementada.

### `servidor`
Cadastro dos servidores do órgão que podem receber tarefas.

**Chave principal:** `id` (INTEGER, autoincrement).

### `tag`
Etiquetas para classificação e filtragem das tarefas.

**Chave principal:** `id` (INTEGER, autoincrement).

### `providencia_tipo`
Tipos de ação/providência que podem ser atribuídas a um processo.

**Chave principal:** `id` (INTEGER, autoincrement).

### `tarefa_servidor`
Registra a atribuição de uma providência sobre um processo a um servidor. Inclui prazo, observações e classificação por tag.

**Chave principal:** `id` (INTEGER, autoincrement).
**Chaves estrangeiras:**
- `numeroProcesso` para `processo(numeroProcesso)` com `ON DELETE CASCADE` — ✅ implementada.
- `servidor_id` para `servidor(id)` — ✅ implementada.
- `providencia_tipo_id` para `providencia_tipo(id)` — ✅ implementada.
- `tag_id` para `tag(id)` — ✅ implementada (nullable).

---

## 3. Relacionamentos e cardinalidades

| Tabela A | Cardinalidade | Tabela B | Implementação |
|---|---|---|---|
| `processo` | 1 : N | `processo_movimentacao` | FK formal (`numeroProcesso → processo.numeroProcesso`) |
| `processo` | 1 : N | `analise_ia_processo` | FK formal (`numeroProcesso → processo.numeroProcesso`) |
| `processo` | N : N | `norma` | Via `processo_citacao_norma` (FK formal `numeroProcesso`) |
| `processo` | 1 : N | `tarefa_servidor` | FK formal (`numeroProcesso → processo.numeroProcesso`) |
| `servidor` | 1 : N | `tarefa_servidor` | FK formal (`servidor_id → servidor.id`) |
| `providencia_tipo` | 1 : N | `tarefa_servidor` | FK formal (`providencia_tipo_id → providencia_tipo.id`) |
| `tag` | 0..1 : N | `tarefa_servidor` | FK formal (`tag_id → tag.id`), nullable |

---

## 4. Chaves primárias e estrangeiras

### Chaves primárias

| Tabela | Chave primária | Tipo | Observação |
|---|---|---|---|
| `processo` | `numeroProcesso` | TEXT | Chave primária oficial e natural do processo (CNJ) |
| `processo_movimentacao` | `id` | INTEGER AUTOINCREMENT | — |
| `analise_ia_processo` | `id` | INTEGER AUTOINCREMENT | — |
| `norma` | `id` | INTEGER AUTOINCREMENT | + UNIQUE em `nome` |
| `processo_citacao_norma` | `(numeroProcesso, norma_id)` | COMPOSTA | Chave primária composta |
| `servidor` | `id` | INTEGER AUTOINCREMENT | — |
| `tag` | `id` | INTEGER AUTOINCREMENT | — |
| `providencia_tipo` | `id` | INTEGER AUTOINCREMENT | — |
| `tarefa_servidor` | `id` | INTEGER AUTOINCREMENT | — |

### Chaves estrangeiras

| Tabela | Coluna | Referência | Status |
|---|---|---|---|
| `processo_movimentacao` | `numeroProcesso` | `processo(numeroProcesso)` | ✅ Implementada (`ON DELETE CASCADE`) |
| `analise_ia_processo` | `numeroProcesso` | `processo(numeroProcesso)` | ✅ Implementada (`ON DELETE CASCADE`) |
| `processo_citacao_norma` | `numeroProcesso` | `processo(numeroProcesso)` | ✅ Implementada (`ON DELETE CASCADE`) |
| `processo_citacao_norma` | `norma_id` | `norma(id)` | ✅ Implementada (`ON DELETE CASCADE`) |
| `tarefa_servidor` | `numeroProcesso` | `processo(numeroProcesso)` | ✅ Implementada (`ON DELETE CASCADE`) |
| `tarefa_servidor` | `servidor_id` | `servidor(id)` | ✅ Implementada |
| `tarefa_servidor` | `providencia_tipo_id` | `providencia_tipo(id)` | ✅ Implementada |
| `tarefa_servidor` | `tag_id` | `tag(id)` | ✅ Implementada (nullable) |

---

## 5. Problemas de normalização encontrados

### 5.1. `assuntos_codigos` e `assuntos_nomes` — violação da 1FN

**Estrutura atual:**
```sql
assuntos_codigos TEXT,  -- ex: "10096 | 9994"
assuntos_nomes   TEXT,  -- ex: "Bloqueio de Valores | Indenização por Dano Ambiental"
```

**Problema:** Esses campos armazenam listas de valores separadas por `|`, violando a Primeira Forma Normal (1FN), que exige que cada coluna contenha valores atômicos.

**Solução normativa (proposta, não implementada):**
```sql
CREATE TABLE processo_assunto (
    numeroProcesso TEXT NOT NULL,
    assunto_codigo TEXT NOT NULL,
    assunto_nome   TEXT,
    PRIMARY KEY (numeroProcesso, assunto_codigo),
    FOREIGN KEY (numeroProcesso) REFERENCES processo(numeroProcesso) ON DELETE CASCADE
);
```

**Decisão atual:** ⚠️ **Mantido desnormalizado por compatibilidade com a API Pública do DataJud (CNJ).**

Os dados são oriundos da [API Pública do DataJud](https://datajud-wiki.cnj.jus.br/api-publica/glossario) e seguem as Tabelas Processuais Unificadas (TPU) do CNJ, onde um mesmo processo pode acumular múltiplos códigos de assunto. Normalizar exigiria um parser dedicado na ingestão Python e quebraria a compatibilidade com ferramentas que consomem o formato bruto padronizado do governo.

**Cuidados:** Consultas que filtram por assunto específico devem usar `LIKE '%codigo%'`, o que é menos eficiente do que uma FK.

---

### 5.2. `complementosTabelados_*` — violação da 1FN em `processo_movimentacao`

**Estrutura atual:**
```sql
complementosTabelados_codigo    TEXT,  -- ex: "17 | 2"
complementosTabelados_descricao TEXT,  -- ex: "motivo_da_redistribuicao | tipo_de_distribuicao_redistribuicao"
complementosTabelados_valor     TEXT,  -- ex: "83 | 2"
complementosTabelados_nome      TEXT,  -- ex: "incompetência | sorteio"
```

**Problema:** Mesma situação — listas multivaloradas numa única coluna, violando a 1FN. Adicionalmente, cada movimentação pode ter zero ou múltiplos complementos tabelados, o que caracteriza um grupo repetido (violação da 1FN em outra perspectiva).

**Solução normativa (proposta, não implementada):**
```sql
CREATE TABLE movimentacao_complemento (
    id                   INTEGER PRIMARY KEY AUTOINCREMENT,
    movimentacao_id      INTEGER NOT NULL,
    comp_codigo          TEXT,
    comp_descricao       TEXT,
    comp_valor           TEXT,
    comp_nome            TEXT,
    FOREIGN KEY (movimentacao_id) REFERENCES processo_movimentacao(id)
);
```

**Decisão atual:** ⚠️ **Mantido desnormalizado por compatibilidade e rastreabilidade com a API.**

Os complementos tabelados chegam como arrays aninhados na resposta da API. A estrutura atual preserva os dados brutos para rastreabilidade. A normalização exigiria alterações significativas na camada de ingestão.

---

### 5.3. `movimentos_quantidadeTotal` — tipo de dado inadequado

**Estrutura atual:**
```sql
movimentos_quantidadeTotal TEXT
```

**Problema:** O campo representa uma quantidade (número inteiro), mas está tipado como TEXT. Isso não viola formas normais, mas dificulta ordenações e comparações numéricas.

**Alteração proposta:** 💡
```sql
movimentos_quantidadeTotal INTEGER
```

**Status:** ⚠️ **Aguarda confirmação.** Alterar o tipo em um banco existente requer migração. Verificar se a aplicação Python faz conversão explícita antes de decidir.

---

### 5.4. Ausência de restrição `UNIQUE` em tabelas de domínio

**Tabelas afetadas:** `servidor`, `tag`, `providencia_tipo`

**Problema:** Nenhuma dessas tabelas possui restrição `UNIQUE` em `nome`, o que permite inserir registros duplicados.

**Exemplo:**
```sql
-- Isso seria aceito sem restrição UNIQUE:
INSERT INTO tag (nome) VALUES ('Urgente');
INSERT INTO tag (nome) VALUES ('Urgente'); -- duplicata silenciosa
```

**Alteração proposta:** 💡 Adicionar `UNIQUE` em `nome` para as três tabelas:
```sql
-- Alterar em 01_create_tables.sql:
CREATE TABLE IF NOT EXISTS servidor (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE   -- <-- adicionar UNIQUE
);

CREATE TABLE IF NOT EXISTS tag (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS providencia_tipo (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE
);
```

**Status:** ⚠️ **Aguarda confirmação.** Em um banco já existente, a constraint não é adicionada retroativamente por `CREATE TABLE IF NOT EXISTS`. Seria necessária uma migração com `ALTER TABLE` ou recriação da tabela.

---

### 5.5. Unificação da Chave Primária e Chaves Estrangeiras em `numeroProcesso`

**Decisão implementada:** ✅
- A tabela `processo` adotou `numeroProcesso TEXT PRIMARY KEY` como sua chave primária oficial e natural.
- Todas as tabelas dependentes (`processo_movimentacao`, `analise_ia_processo`, `processo_citacao_norma` e `tarefa_servidor`) utilizam a coluna chamada exclusivamente `numeroProcesso TEXT` como chave estrangeira com integridade referencial formal (`FOREIGN KEY (numeroProcesso) REFERENCES processo(numeroProcesso) ON DELETE CASCADE`).
- **Justificativa do tipo `TEXT`:** Números CNJ possuem 20 dígitos (ex.: `'30672998720268060001'`). Como o inteiro máximo de 64 bits suportado pelo SQLite é `9.223.372.036.854.775.807` (~9,22 × 10¹⁸), números de 20 dígitos sofrem estouro de precisão se tipados como `INTEGER` e perdem zeros à esquerda (ex.: `'00468052320188060071'`). O tipo `TEXT` garante integridade completa sem perda de dados.

---

### 5.6. Redundância em `processo_movimentacao`

**Problema:** Os campos `classe_nome` e `orgaoJulgador_capa` em `processo_movimentacao` replicam dados já presentes na tabela `processo`. Isso viola a 3FN, pois esses atributos dependem funcionalmente do processo, não da movimentação em si.

**Análise:** O dado foi incluído provavelmente para facilitar consultas sem JOIN. Dado o volume de movimentações (~29 mil registros), a redundância tem impacto de armazenamento, mas também tem justificativa de performance.

**Decisão:** 💡 **Recomendado remover** `classe_nome` e `orgaoJulgador_capa` de `processo_movimentacao` a longo prazo, substituindo por JOIN com `processo`. No curto prazo, mantém-se a estrutura atual para não impactar a ingestão.

---

## 6. Melhorias implementadas nesta revisão

| Melhoria | Arquivo | Descrição |
|---|---|---|
| `.gitignore` | `.gitignore` | Bloqueia `.db`, `.DS_Store`, caches Python e IDEs. |
| Script seed | `DML/01_seed_referencia.sql` | Dados de domínio com `INSERT OR IGNORE` (idempotente). |
| Chave primária `numeroProcesso` | `DDL/01_create_tables.sql` | `processo(numeroProcesso TEXT PRIMARY KEY)` implementada. |
| FKs unificadas em `numeroProcesso` | `DDL/01_create_tables.sql` | `analise_ia_processo`, `processo_movimentacao`, `processo_citacao_norma` e `tarefa_servidor` padronizadas com `numeroProcesso` como FK formal. |
| `README.md` | `README.md` | Documentação completa com instruções de execução e ordem dos scripts. |
| Documentação técnica | `MODELAGEM_E_NORMALIZACAO.md` | Análise relacional completa e justificativas técnicas. |

---

## 7. Melhorias propostas que dependem de confirmação

| # | Proposta | Impacto | Prioridade |
|---|---|---|---|
| 1 | Adicionar `UNIQUE` em `nome` de `servidor`, `tag` e `providencia_tipo` | Baixo — apenas DDL | Alta |
| 2 | Normalizar `assuntos_codigos`/`assuntos_nomes` em tabela própria | Médio — altera ingestão Python | Média |
| 3 | Normalizar `complementosTabelados_*` em tabela própria | Alto — altera ingestão Python | Baixa (dado de rastreabilidade) |
| 4 | Alterar `movimentos_quantidadeTotal` de TEXT para INTEGER | Baixo — requer migração se banco existir | Média |
| 5 | Remover `classe_nome` e `orgaoJulgador_capa` de `processo_movimentacao` | Médio — altera ingestão Python | Baixa |
| 6 | Adicionar índices em colunas de busca frequente | Baixo — apenas DDL | Média |

---

## 8. Índices recomendados

Os índices a seguir são recomendados para melhorar a performance de consultas frequentes:

```sql
-- 💡 RECOMENDADOS — não aplicados ainda, aguardam confirmação

-- Busca de processo por número CNJ (chave de negócio mais usada)
CREATE INDEX IF NOT EXISTS idx_processo_numeroProcesso ON processo(numeroProcesso);

-- Busca de movimentações por processo
CREATE INDEX IF NOT EXISTS idx_movimentacao_numeroProcesso ON processo_movimentacao(numeroProcesso);
CREATE INDEX IF NOT EXISTS idx_movimentacao_id_processo ON processo_movimentacao(id_processo);

-- Busca de análises por processo
CREATE INDEX IF NOT EXISTS idx_analise_numeroProcesso ON analise_ia_processo(numeroProcesso);

-- Busca de tarefas por processo e servidor
CREATE INDEX IF NOT EXISTS idx_tarefa_processo ON tarefa_servidor(numeroProcesso);
CREATE INDEX IF NOT EXISTS idx_tarefa_servidor ON tarefa_servidor(servidor_id);
```

---

## 9. Cuidados para manter a integridade dos dados

1. **Sempre ativar `PRAGMA foreign_keys = ON`** em cada conexão SQLite, tanto na CLI quanto na aplicação Python.
2. **Não inserir processos diretamente sem passar pela aplicação** — o campo `id_tjce` é gerado pela aplicação com um padrão específico (`TJCE_G1_<numeroProcesso>`).
3. **Não re-executar os scripts de carga** (`inserts_processo.sql`, `inserts_analise_ia_processo.sql`, `inserts_processo_movimentacao.sql`) em um banco que já contenha dados — eles não usam `INSERT OR IGNORE` e gerarão duplicatas.
4. **Não alterar a estrutura DDL de tabelas existentes** com `ALTER TABLE` sem primeiro verificar se a aplicação Python e as consultas existentes são compatíveis.
5. **Antes de deletar registros de `processo`**, verificar dependências em `processo_movimentacao`, `analise_ia_processo`, `processo_citacao_norma` e `tarefa_servidor` (com FK formal para as últimas duas).
