---
plano-id: SPEC-2026-010
spec-relacionada: SPEC-2026-010
titulo: Plano de Implementação — Autenticação por PIN
versao: 0.1.0
status: rascunho
atualizado-em: 2026-08-06
tags: [plano, autenticacao]
---

# SPEC-2026-010: Plano — Autenticação por PIN

## 🧭 Contexto resumido
Executa a spec `SPEC-2026-010`. Objetivo: entregar a tela de login por PIN com navegação segura para a lista de escolas.

## 📅 Fases de trabalho

### Fase 1 — Contratos
- Modelo `AuthState` e `AuditorModel`.

### Fase 2 — Mocks
- Credenciais mockadas de auditor com PIN de teste `1234`.

### Fase 3 — Estado/store + invariantes
- Integração do fluxo de login em `AuditProvider` ou `AuthProvider`.

### Fase 4 — UI + rotas + menu
- Tela `PinInputWidget` e `LoginScreen` com rota `/login`.

### Fase 5 — Testes
- Teste unitário de validação de PIN e teste de widget da tela de login.

### Fase 6 — Guardião
- Aprovação do spec-guardian e checagem de lints.
