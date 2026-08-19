---
plano-id: SPEC-2026-020
spec-relacionada: SPEC-2026-020
titulo: Plano de Implementação — Gestão de Escolas
versao: 0.1.0
status: rascunho
atualizado-em: 2026-08-06
tags: [plano, escolas]
---

# SPEC-2026-020: Plano — Gestão de Escolas

## 🧭 Contexto resumido
Executa a spec `SPEC-2026-020`. Objetivo: disponibilizar a tela de lista de escolas com filtros e indicadores de progresso.

## 📅 Fases de trabalho

### Fase 1 — Contratos
- Modelo `EscolaModel` com id, nome, código, região e estatísticas de progresso.

### Fase 2 — Mocks
- Lista mockada de escolas da região com dados de amostra.

### Fase 3 — Estado/store + invariantes
- Getters e métodos de busca/filtragem no `AuditProvider`.

### Fase 4 — UI + rotas + menu
- `EscolasScreen` com barra de busca, cards e rotas.

### Fase 5 — Testes
- Testes unitários para lógica de busca e testes de widget do card da escola.

### Fase 6 — Guardião
- Validação pelo spec-guardian.
