---
plano-id: SPEC-2026-040
spec-relacionada: SPEC-2026-040
titulo: Plano de Implementação — Registro de Ativo e Foto
versao: 0.1.0
status: rascunho
atualizado-em: 2026-08-06
tags: [plano, foto, registro]
---

# SPEC-2026-040: Plano — Registro de Ativo e Foto

## 🧭 Contexto resumido
Executa a spec `SPEC-2026-040`. Objetivo: disponibilizar o formulário de auditoria individual de ativo com captura de foto.

## 📅 Fases de trabalho

### Fase 1 — Contratos
- Atualização do modelo `AtivoModel` para suportar observações e foto.

### Fase 2 — Mocks
- Serviço mock de câmera/imagem para testes automatizados.

### Fase 3 — Estado/store + invariantes
- Validação de foto obrigatória para avarias em `AuditProvider`.

### Fase 4 — UI + rotas + menu
- `RegistroAtivoScreen`, `FotoCapturaWidget` e `StatusSelectorWidget` (`/item-register`).

### Fase 5 — Testes
- Testar regra de bloqueio sem foto em status de avaria/ausente.

### Fase 6 — Guardião
- Validação spec-guardian.
