---
doc-id: API
titulo: Contrato de API — Via Audit
versao: 1.0.0
status: aprovada
atualizado-em: 2026-08-06
tipo: discovery
tags: [discovery, api]
---

# API & Sincronização `[inferido]` / `[código]`

## Cliente HTTP `[código]`
- **Engine:** `dio` (5.5.0)
- **Modo:** Offline-first com cache local em `sqflite` e sincronização via REST quando há conectividade (`connectivity_plus`).

## Endpoints Previstos da Retaguarda `[inferido]`
- `POST /api/v1/auth/login` — Autenticação do auditor.
- `GET /api/v1/audits/assigned` — Obter lista de escolas e contratos de comodato atribuídos.
- `POST /api/v1/audits/{id}/sync` — Enviar dados de auditoria, etiquetas patrimoniais lidas, coordenadas e assinatura digital coletada.
