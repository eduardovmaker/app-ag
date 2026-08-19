---
doc-id: BACKLOG
titulo: Backlog e Dívidas — Via Audit
versao: 1.0.0
status: aprovada
atualizado-em: 2026-08-06
tipo: discovery
tags: [discovery, backlog]
---

# Backlog `[código]` / `[inferido]`

## Features Implementadas (Passo C-existente) `[código]`
- [x] Interface base e navegação entre telas (`/login`, `/schools`, `/checklist`, `/item-register`, `/visit-summary`).
- [x] Estado reativo de auditoria em memória com `AuditProvider`.
- [x] Componentes visuais reutilizáveis (`lib/core/widgets/`).
- [x] Layout com design system customizado (`AppColors`, `AppTextStyles`, `AppTheme`).

## Itens de Backlog / Próximos Passos `[inferido]`
- [ ] Integração com banco SQLite (`sqflite`) para retenção persistente offline.
- [ ] Leitor de QR Code / Código de Barras via câmera para leitura rápida de etiqueta de patrimônio.
- [ ] Conexão com API REST via `Dio` para sincronização remota dos relatórios de auditoria.
- [ ] Captura de coordenadas GPS reais via `geolocator` ao salvar a auditoria.
