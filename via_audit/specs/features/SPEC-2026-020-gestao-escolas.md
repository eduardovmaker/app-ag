---
spec-id: SPEC-2026-020
titulo: Gestão e Listagem de Escolas
versao: 1.0.0
status: implementada
autor: eduardo.martins@viaeducat.com.br
criado-em: 2026-08-06
atualizado-em: 2026-08-06
tipo: feature
cas: 3
depende-de: [SPEC-2026-010]
tags: [escolas, listagem, filtros]
---

# SPEC-2026-020: Gestão e Listagem de Escolas

## 📌 Resumo Executivo

Apresentar a lista de colégios vinculados à região do Orientador Educacional/Auditor, permitindo busca por nome/código, filtragem por status da auditoria (pendente, em andamento, concluída) e exibição do progresso de conferência.

## 🎯 Contexto e Motivação

- **Problema atual:** Dificuldade em visualizar quais escolas necessitam de auditoria imediata e em qual região se encontram.
- **Por que agora:** Necessário para organizar a jornada de visitas do auditor em campo.

## ✅ Objetivos

1. Exibir cards das escolas com progresso relativo de ativos auditados.
2. Permitir a filtragem dinâmica por nome/código da escola e região.

## ❌ Não-Objetivos

1. Cadastro de novas escolas diretamente pelo app mobile.

## 📋 Requisitos

### Funcionais
- **RF-01**: Listar escolas cadastradas com nome, código, cidade e status de visita.
- **RF-02**: Filtro de pesquisa textual por nome ou código do colégio.
- **RF-03**: Exibir indicador percentual de ativos auditados em cada card.

## ✅ Critérios de Aceitação

- **CA-01**: Busca por termo "Álamo" filtra corretamente a lista mantendo apenas escolas com esse termo no nome.
- **CA-02**: Selecionar uma escola na lista direciona o usuário para o checklist correspondente (`/checklist`).
- **CA-03**: Card da escola exibe contagem precisa de ativos auditados vs. total de ativos.
