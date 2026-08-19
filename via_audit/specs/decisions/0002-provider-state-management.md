---
id: ADR-2026-0002
titulo: Gerenciamento de Estado Reativo com Provider
status: aceito
data: 2026-08-06
autor: Engenharia Reversa SDD Kit
---

# ADR-2026-0002 — Gerenciamento de Estado Reativo com Provider

> **Nota:** Documentado por engenharia reversa.

## Contexto
O aplicativo precisa gerenciar o estado global do checklist de auditoria, lista de escolas e progresso da visita de forma reativa e previsível entre as diversas telas da aplicação.

## Decisão
Utilizar a biblioteca `provider` com `ChangeNotifier` (`AuditProvider`) como solução padrão de gerenciamento de estado.

## Consequências
- **Positivas:** Simplicidade de implementação, integração nativa com o ecossistema Flutter, baixo boilerplate.
- **Negativas:** Requer atenção para evitar chamadas excessivas de `notifyListeners()`.
