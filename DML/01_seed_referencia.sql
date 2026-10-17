-- ============================================================
-- Projeto: TJCE VEMA SOIN — Sistema de Organização de Informações Ambientais
-- Arquivo: DML/01_seed_referencia.sql
-- Responsabilidade: Dados de referência (tabelas de domínio)
-- Execução: Uma vez, antes dos demais scripts DML.
-- Pode ser re-executado com segurança (INSERT OR IGNORE).
-- SGBD: SQLite
-- ============================================================

-- ------------------------------------------------------------
-- Servidores responsáveis pelas tarefas
-- Ajuste os nomes conforme os servidores reais do projeto.
-- ------------------------------------------------------------
INSERT OR IGNORE INTO servidor (id, nome) VALUES (1, 'Servidor A');
INSERT OR IGNORE INTO servidor (id, nome) VALUES (2, 'Servidor B');
INSERT OR IGNORE INTO servidor (id, nome) VALUES (3, 'Servidor C');

-- ------------------------------------------------------------
-- Tags de classificação das tarefas
-- ------------------------------------------------------------
INSERT OR IGNORE INTO tag (id, nome) VALUES (1, 'Urgente');
INSERT OR IGNORE INTO tag (id, nome) VALUES (2, 'Análise Pendente');
INSERT OR IGNORE INTO tag (id, nome) VALUES (3, 'Aguardando Documentação');
INSERT OR IGNORE INTO tag (id, nome) VALUES (4, 'Em Andamento');

-- ------------------------------------------------------------
-- Tipos de providência
-- ------------------------------------------------------------
INSERT OR IGNORE INTO providencia_tipo (id, nome) VALUES (1, 'Notificação');
INSERT OR IGNORE INTO providencia_tipo (id, nome) VALUES (2, 'Autuação');
INSERT OR IGNORE INTO providencia_tipo (id, nome) VALUES (3, 'Diligência');
INSERT OR IGNORE INTO providencia_tipo (id, nome) VALUES (4, 'Arquivamento');

-- ------------------------------------------------------------
-- Normas jurídicas recorrentemente citadas nos processos
-- Baseadas nos dados observados nos scripts DML de processos.
-- Use INSERT OR IGNORE para evitar duplicação em re-execuções.
-- ------------------------------------------------------------
INSERT OR IGNORE INTO norma (nome) VALUES ('Lei nº 9.605/1998 — Lei de Crimes Ambientais');
INSERT OR IGNORE INTO norma (nome) VALUES ('Lei nº 12.651/2012 — Código Florestal');
INSERT OR IGNORE INTO norma (nome) VALUES ('Resolução CONAMA nº 237/1997 — Licenciamento Ambiental');
INSERT OR IGNORE INTO norma (nome) VALUES ('Resolução CONAMA nº 303/2002 — Áreas de Preservação Permanente');
INSERT OR IGNORE INTO norma (nome) VALUES ('Lei nº 9.433/1997 — Política Nacional de Recursos Hídricos');
INSERT OR IGNORE INTO norma (nome) VALUES ('Decreto nº 6.514/2008 — Infrações Ambientais');

-- ============================================================
-- FIM DO SCRIPT DE DADOS DE REFERÊNCIA
-- ============================================================
