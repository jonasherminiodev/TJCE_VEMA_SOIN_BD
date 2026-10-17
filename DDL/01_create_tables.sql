-- ============================================================
-- Projeto: TJCE VEMA SOIN — Banco de Dados
-- Arquivo: DDL/01_create_tables.sql
-- SGBD: SQLite
-- Descrição: Cria a estrutura de tabelas do sistema.
--            Chave primária de processo: numeroProcesso (TEXT)
--            Chaves estrangeiras unificadas por numeroProcesso
-- ============================================================

PRAGMA foreign_keys = ON;

-- ============================================================
-- 1. DADOS DE PROCESSOS JUDICIAIS
-- ============================================================

-- 1.1. Processos obtidos da API (Chave primária: numeroProcesso)
CREATE TABLE IF NOT EXISTS processo (
    numeroProcesso TEXT PRIMARY KEY,
    id_tjce TEXT,
    tribunal TEXT,
    dataAjuizamento TEXT,
    grau TEXT,
    nivelSigilo TEXT,
    formato_codigo TEXT,
    formato_nome TEXT,
    sistema_codigo TEXT,
    sistema_nome TEXT,
    classe_codigo TEXT,
    classe_nome TEXT,
    orgaoJulgador_codigo TEXT,
    orgaoJulgador_nome TEXT,
    orgaoJulgador_codigoMunicipioIBGE TEXT,
    assuntos_codigos TEXT,
    assuntos_nomes TEXT,
    movimentos_quantidadeTotal TEXT,
    ultimoMovimento_codigo TEXT,
    ultimoMovimento_nome TEXT,
    ultimoMovimento_dataHora TEXT,
    dataHoraUltimaAtualizacao TEXT,
    timestamp TEXT
);

-- 1.2. Movimentações dos processos judiciais
CREATE TABLE IF NOT EXISTS processo_movimentacao (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    numeroProcesso TEXT NOT NULL,
    id_processo TEXT,
    classe_nome TEXT,
    orgaoJulgador_capa TEXT,
    ordem_movimento TEXT,
    movimentos_dataHora TEXT,
    movimentos_codigo TEXT,
    movimentos_nome TEXT,
    movimentos_orgaoJulgador_codigoOrgao TEXT,
    movimentos_orgaoJulgador_nomeOrgao TEXT,
    complementosTabelados_codigo TEXT,
    complementosTabelados_descricao TEXT,
    complementosTabelados_valor TEXT,
    complementosTabelados_nome TEXT,
    FOREIGN KEY (numeroProcesso) REFERENCES processo(numeroProcesso) ON DELETE CASCADE
);

-- ============================================================
-- 2. ANÁLISE E REFERÊNCIAS JURÍDICAS
-- ============================================================

-- 2.1. Análises realizadas pela IA
CREATE TABLE IF NOT EXISTS analise_ia_processo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    numeroProcesso TEXT NOT NULL,
    localidade TEXT,
    municipio TEXT,
    bairro_regiao TEXT,
    latitude REAL DEFAULT 0,
    longitude REAL DEFAULT 0,
    ecossistema TEXT,
    resumo_sintetico TEXT,
    FOREIGN KEY (numeroProcesso) REFERENCES processo(numeroProcesso) ON DELETE CASCADE
);

-- 2.2. Normas jurídicas cadastradas
CREATE TABLE IF NOT EXISTS norma (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT UNIQUE NOT NULL
);

-- 2.3. Associação entre processos e normas citadas (N:N)
CREATE TABLE IF NOT EXISTS processo_citacao_norma (
    numeroProcesso TEXT NOT NULL,
    norma_id INTEGER NOT NULL,
    PRIMARY KEY (numeroProcesso, norma_id),
    FOREIGN KEY (numeroProcesso) REFERENCES processo(numeroProcesso) ON DELETE CASCADE,
    FOREIGN KEY (norma_id) REFERENCES norma(id) ON DELETE CASCADE
);

-- ============================================================
-- 3. GESTÃO DE TAREFAS E PROVIDÊNCIAS
-- ============================================================

-- 3.1. Servidores responsáveis pelas tarefas
CREATE TABLE IF NOT EXISTS servidor (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL
);

-- 3.2. Tags para classificação das tarefas
CREATE TABLE IF NOT EXISTS tag (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL
);

-- 3.3. Tipos de providência
CREATE TABLE IF NOT EXISTS providencia_tipo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL
);

-- 3.4. Tarefas atribuídas aos servidores
CREATE TABLE IF NOT EXISTS tarefa_servidor (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    numeroProcesso TEXT NOT NULL,
    servidor_id INTEGER NOT NULL,
    providencia_tipo_id INTEGER NOT NULL,
    tag_id INTEGER,
    obs_providencia TEXT,
    data_entrega DATE,
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (numeroProcesso) REFERENCES processo(numeroProcesso) ON DELETE CASCADE,
    FOREIGN KEY (servidor_id) REFERENCES servidor(id),
    FOREIGN KEY (providencia_tipo_id) REFERENCES providencia_tipo(id),
    FOREIGN KEY (tag_id) REFERENCES tag(id)
);

-- ============================================================
-- FIM DO SCRIPT DE CRIAÇÃO DAS TABELAS
-- ============================================================