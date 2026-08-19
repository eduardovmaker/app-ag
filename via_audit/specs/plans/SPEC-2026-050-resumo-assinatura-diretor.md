---
plano-id: SPEC-2026-050
spec-relacionada: SPEC-2026-050
titulo: Plano de Implementação — Resumo e Assinatura do Diretor
versao: 0.1.0
status: rascunho
atualizado-em: 2026-08-06
tags: [plano, resumo, assinatura]
---

# SPEC-2026-050: Plano — Resumo e Assinatura do Diretor

## 🧭 Contexto resumido
Executa a spec `SPEC-2026-050`. Objetivo: criar a tela de consolidação da visita e coleta de assinatura digital do Diretor.

## 📅 Fases de trabalho

### Fase 1 — Contratos
- Modelo `VisitaResumoModel` e `AssinaturaModel`.

### Fase 2 — Mocks
- Mock de geração de termo de responsabilidade.

### Fase 3 — Estado/store + invariantes
- Validação de encerramento de visita em `AuditProvider`.

### Fase 4 — UI + rotas + menu
- `FinalizarVisitaScreen`, `ResumoCardWidget` e `AssinaturaCanvasWidget` (`/visit-summary`).

### Fase 5 — Testes
- Testar obrigatoriedade de assinatura e alteração de status da visita para concluída.

### Fase 6 — Guardião
- Aprovação spec-guardian e suíte verde.
