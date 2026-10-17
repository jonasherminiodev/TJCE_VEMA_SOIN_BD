# TJCE VEMA SOIN — Banco de Dados

**Sistema de Organização de Informações da Vara Estadual do Meio Ambiente do TJCE**

---

## Descrição e finalidade do repositório

Este repositório contém os scripts SQL que definem, organizam e populam o banco de dados do projeto **TJCE VEMA SOIN** (*Sistema de Organização de Informações da Vara Estadual do Meio Ambiente do TJCE*).

O banco de dados foi projetado para centralizar, estruturar e enriquecer informações processuais ambientais, permitindo consultas analíticas, triagem inteligente com IA e controle interno de demandas.

A estrutura armazena:
- **Capa e metadados de processos judiciais** ambientais que tramitam na VEMA.
- **Histórico cronológico de movimentações processuais** com detalhes tabelados de cada ato.
- **Análises sintetizadas por Inteligência Artificial**, incluindo ecossistema, resumo temático e contextualização geoespacial (município, bairro/região, latitude e longitude).
- **Normas jurídicas e ambientais** citadas nos autos (relação N:N).
- **Gestão operacional e fluxo de trabalho interno:** cadastro de servidores, tarefas atribuídas, prazos, tipos de providência e etiquetas de classificação (*tags*).

---

## Fonte e Origem dos Dados (DataJud / CNJ)

A maior parte dos dados processuais operacionais deste banco foi obtida a partir da **API Pública do DataJud** (Base Nacional de Dados do Poder Judiciário), mantida pelo **Conselho Nacional de Justiça (CNJ)** em cooperação com o **Tribunal de Justiça do Estado do Ceará (TJCE)**.

A modelagem das tabelas `processo` e `processo_movimentacao` reflete a padronização oficial do Poder Judiciário brasileiro:
- **Tabelas Processuais Unificadas (TPU/CNJ):** códigos e nomenclaturas oficiais para classes processuais, assuntos jurídicos e eventos de movimentação.
- **Campos e Metadados Oficiais:** sistemas de tramitação (ex.: PJe), graus de jurisdição, órgãos julgadores, municípios IBGE e complementos tabelados de movimentação.

> 📖 Para entender o significado, formato e tipos de dados de cada atributo processual retornado pela API oficial do governo, consulte o [Glossário da API Pública do DataJud (CNJ)](https://datajud-wiki.cnj.jus.br/api-publica/glossario).

---

## Contexto de utilização

O banco é criado e acessado por uma aplicação Python. Os scripts deste repositório **não substituem a inicialização feita pela aplicação** — eles documentam a estrutura, permitem recriar o banco manualmente em um ambiente de desenvolvimento ou teste, e servem de referência para a equipe.

> **Importante:** A aplicação Python é responsável por habilitar as chaves estrangeiras (`PRAGMA foreign_keys = ON`) em cada conexão SQLite. O script DDL também emite esse comando, mas ele só tem efeito na sessão em que é executado diretamente via CLI.

---

## Tecnologias e pré-requisitos

| Componente | Versão / Observação |
|---|---|
| SQLite | 3.x (já incluso no macOS e na maioria das distribuições Linux) |
| Python | 3.x (para execução pela aplicação) |
| Shell | bash ou zsh (para execução manual dos scripts) |

Para verificar a versão do SQLite disponível:

```bash
sqlite3 --version
```

---

## Estrutura de diretórios

```
TJCE_VEMA_SOIN_BD/
├── .gitignore                         # Arquivos ignorados pelo Git
├── README.md                          # Este documento
├── MODELAGEM_E_NORMALIZACAO.md        # Documentação técnica do modelo de dados
│
├── DDL/
│   └── 01_create_tables.sql           # Criação de todas as tabelas (DDL)
│
└── DML/
    ├── 01_seed_referencia.sql         # Dados de referência (servidores, tags, normas etc.)
    ├── inserts_processo.sql           # Carga de processos judiciais (200 registros)
    ├── inserts_analise_ia_processo.sql # Carga de análises da IA (200 registros)
    ├── inserts_processo_movimentacao.sql # Carga de movimentações (~29.470 registros)
    └── inserts_popula.sql             # Arquivo vazio (reservado para uso futuro)
```

### Descrição dos arquivos

| Arquivo | Tipo | Descrição |
|---|---|---|
| `DDL/01_create_tables.sql` | DDL | Cria todas as 9 tabelas do banco com chaves primárias, estrangeiras e restrições |
| `DML/01_seed_referencia.sql` | DML / Seed | Insere dados de domínio: servidores, tags, tipos de providência e normas. Idempotente. |
| `DML/inserts_processo.sql` | DML | Insere 200 processos obtidos da API do TJCE |
| `DML/inserts_analise_ia_processo.sql` | DML | Insere 200 análises geradas por IA para os processos |
| `DML/inserts_processo_movimentacao.sql` | DML | Insere ~29.470 movimentações processuais |
| `DML/inserts_popula.sql` | DML | Arquivo vazio, reservado para expansão futura |

---

## Principais tabelas e suas responsabilidades

### Dados de processos judiciais

| Tabela | Responsabilidade |
|---|---|
| `processo` | Armazena a capa de cada processo judicial obtido da API do TJCE. Cada linha representa um processo único. |
| `processo_movimentacao` | Armazena todas as movimentações (histórico de atos) de cada processo. Uma linha por movimentação. |

### Análise e referências jurídicas

| Tabela | Responsabilidade |
|---|---|
| `analise_ia_processo` | Armazena o resumo analítico gerado por IA para cada processo, incluindo localidade, município, bairro/região, coordenadas geográficas (latitude/longitude) e ecossistema. |
| `norma` | Catálogo de normas jurídicas cadastradas. |
| `processo_citacao_norma` | Tabela de associação N:N entre processos e normas citadas. |

### Gestão de tarefas e providências

| Tabela | Responsabilidade |
|---|---|
| `servidor` | Cadastro dos servidores responsáveis pelo acompanhamento dos processos. |
| `tag` | Etiquetas para classificação das tarefas. |
| `providencia_tipo` | Tipos de providência que podem ser atribuídas a um processo. |
| `tarefa_servidor` | Vincula um processo a um servidor, com tipo de providência, tag, prazo e observações. |

---

## Relacionamentos entre as tabelas

```
processo (numeroProcesso PK) ─────── (N) processo_movimentacao (numeroProcesso FK)
processo (numeroProcesso PK) ─────── (N) analise_ia_processo (numeroProcesso FK)
processo (numeroProcesso PK) ── processo_citacao_norma ── (1) norma (id PK)   [N:N]
processo (numeroProcesso PK) ─────── (N) tarefa_servidor (numeroProcesso FK)
servidor (id PK) ─────────────────── (N) tarefa_servidor
providencia_tipo (id PK) ─────────── (N) tarefa_servidor
tag (id PK, opcional) ────────────── (N) tarefa_servidor
```

> **Integridade Referencial:** A chave primária oficial da tabela `processo` é `numeroProcesso` (TEXT). Todas as tabelas dependentes (`processo_movimentacao`, `analise_ia_processo`, `processo_citacao_norma` e `tarefa_servidor`) utilizam a coluna padronizada `numeroProcesso` com restrição de chave estrangeira formal (`FOREIGN KEY (numeroProcesso) REFERENCES processo(numeroProcesso) ON DELETE CASCADE`).

---

## Procedimento para clonar o repositório

```bash
git clone <URL-do-repositório>
cd TJCE_VEMA_SOIN_BD
```

---

## Instruções para criar o banco SQLite manualmente

> Use este procedimento apenas para desenvolvimento local, testes ou reconstrução manual do banco. Em produção, a aplicação Python gerencia o banco.

### 1. Criar o banco e aplicar o DDL

```bash
sqlite3 nome_do_banco.db < DDL/01_create_tables.sql
```

### 2. Inserir os dados de referência (seeds)

```bash
sqlite3 nome_do_banco.db < DML/01_seed_referencia.sql
```

### 3. Inserir os processos

```bash
sqlite3 nome_do_banco.db < DML/inserts_processo.sql
```

### 4. Inserir as análises da IA

```bash
sqlite3 nome_do_banco.db < DML/inserts_analise_ia_processo.sql
```

### 5. Inserir as movimentações

> Este script é grande (~29.470 registros). A execução pode levar alguns segundos.

```bash
sqlite3 nome_do_banco.db < DML/inserts_processo_movimentacao.sql
```

---

## Ordem correta de execução

```
DDL/01_create_tables.sql
       ↓
DML/01_seed_referencia.sql
       ↓
DML/inserts_processo.sql
       ↓
DML/inserts_analise_ia_processo.sql
       ↓
DML/inserts_processo_movimentacao.sql
```

**Justificativa da ordem:**

1. O DDL deve ser executado primeiro para criar as tabelas.
2. O seed cria dados de domínio (servidores, tags etc.) referenciados por `tarefa_servidor`.
3. Os processos devem existir antes das análises e movimentações que os referenciam.
4. As movimentações são o maior volume de dados e devem vir por último.

> `inserts_popula.sql` está vazio e pode ser ignorado.

---

## Conferindo a estrutura criada

Após executar os scripts, você pode verificar a estrutura diretamente via CLI do SQLite:

```bash
sqlite3 nome_do_banco.db
```

Dentro do shell interativo do SQLite:

```sql
-- Listar todas as tabelas
.tables

-- Ver a definição de uma tabela
.schema processo

-- Contar registros em cada tabela principal
SELECT 'processo', COUNT(*) FROM processo;
SELECT 'processo_movimentacao', COUNT(*) FROM processo_movimentacao;
SELECT 'analise_ia_processo', COUNT(*) FROM analise_ia_processo;
SELECT 'norma', COUNT(*) FROM norma;
SELECT 'servidor', COUNT(*) FROM servidor;

-- Sair
.quit
```

---

## Chaves estrangeiras e integridade referencial

O SQLite **desabilita** a verificação de chaves estrangeiras por padrão. Para ativá-las:

```sql
PRAGMA foreign_keys = ON;
```

- O script `DDL/01_create_tables.sql` emite esse comando, mas ele vale apenas para a sessão CLI em que é executado.
- **A aplicação Python deve emitir esse PRAGMA em cada conexão** antes de qualquer operação.
- As tabelas `analise_ia_processo`, `processo_movimentacao`, `processo_citacao_norma` e `tarefa_servidor` referenciam formalmente `processo(numeroProcesso)` via FOREIGN KEY (TEXT).

---

## Orientações para adicionar novas tabelas e scripts

1. **DDL:** Adicione a nova tabela ao final de `DDL/01_create_tables.sql`, após as tabelas que ela referencia.
2. **DML / Seed:** Se a tabela contiver dados de domínio, adicione-os em `DML/01_seed_referencia.sql` com `INSERT OR IGNORE`.
3. **DML / Dados operacionais:** Crie um novo arquivo numerado em `DML/`, por exemplo `DML/inserts_nova_tabela.sql`.
4. Atualize este `README.md` com a descrição da nova tabela.
5. Atualize `MODELAGEM_E_NORMALIZACAO.md` com a análise do relacionamento.

---

## Convenções para nomes de arquivos e colaboração

| Tipo | Convenção | Exemplo |
|---|---|---|
| Scripts DDL | `NN_descricao.sql` com prefixo numérico | `01_create_tables.sql` |
| Scripts DML/seed | `NN_seed_descricao.sql` | `01_seed_referencia.sql` |
| Scripts DML/dados | `inserts_tabela.sql` | `inserts_processo.sql` |
| Palavras separadas | underscore (`_`) | ✔ |
| Maiúsculas em nomes de arquivo | Evitar | ✗ |

- **Não versione arquivos `.db`** — o `.gitignore` já os bloqueia.
- **Não inclua credenciais, tokens ou dados pessoais reais** nos scripts.
- **Não altere scripts de carga existentes** para acrescentar registros — crie um novo arquivo numerado.

---

## Limitações conhecidas e pendências

| # | Limitação / Pendência | Classificação |
|---|---|---|
| 1 | `assuntos_codigos` e `assuntos_nomes` armazenam listas separadas por `\|` (pipe) | Desnormalização intencional — veja `MODELAGEM_E_NORMALIZACAO.md` |
| 2 | `complementosTabelados_*` armazenam listas separadas por `\|` nas movimentações | Idem |
| 3 | `inserts_popula.sql` está vazio | Arquivo reservado, sem impacto funcional |
| 4 | `tag` não possui restrição `UNIQUE` em `nome` | Melhoria recomendada — veja `MODELAGEM_E_NORMALIZACAO.md` |
| 5 | `servidor` não possui restrição `UNIQUE` em `nome` | Idem |
| 6 | `providencia_tipo` não possui restrição `UNIQUE` em `nome` | Idem |
| 7 | `movimentos_quantidadeTotal` está tipado como TEXT em vez de INTEGER | Melhoria recomendada |
| 8 | Os scripts DML de carga não usam transações explícitas | Considerar para grandes volumes |

Veja `MODELAGEM_E_NORMALIZACAO.md` para a análise técnica completa de cada item.
