---
plano-id: SPEC-2026-030
spec-relacionada: SPEC-2026-030
titulo: Plano de Implementação — Checklist de Ativos
versao: 0.1.0
status: rascunho
atualizado-em: 2026-08-06
tags: [plano, checklist]
---

# SPEC-2026-030: Plano — Checklist de Ativos

## 🧭 Contexto resumido
Executa a spec `SPEC-2026-030`. Objetivo: criar a tela de checklist dos equipamentos da escola com controle de progresso.

## 📅 Fases de trabalho

### Fase 1 — Contratos
- `AtivoModel` com id, escolaId, patrimonio, numSerie, descricao, status e caminhoFoto.

### Fase 2 — Mocks
- Carga inicial de ativos para escolas de teste.

### Fase 3 — Estado/store + invariantes
- Atualização de status de ativo em `AuditProvider`.

### Fase 4 — UI + rotas + menu
- `ChecklistEscolaScreen` e `AtivoChecklistItemWidget`.

### Fase 5 — Testes
- Testar alternância de status e cálculo de percentual de conclusão.

### Fase 6 — Guardião
- Aprovação do spec-guardian.
