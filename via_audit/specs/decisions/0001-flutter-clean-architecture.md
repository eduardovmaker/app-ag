---
id: ADR-2026-0001
titulo: Uso do Flutter com Clean Architecture por Features
status: aceito
data: 2026-08-06
autor: Engenharia Reversa SDD Kit
---

# ADR-2026-0001 — Uso do Flutter com Clean Architecture por Features

> **Nota:** Documentado por engenharia reversa.

## Contexto
O aplicativo Via Audit necessita ser executado em plataformas móveis (Android e iOS) operando em campo, com interface ágil e suporte nativo a recursos do dispositivo (câmera, localização, banco de dados local).

## Decisão
Adotar **Flutter SDK** com organização de código por **Clean Architecture orientada a Features** (`lib/features/{auth, schools, checklist, item_register, summary}`).

## Consequências
- **Positivas:** Reuso de código em múltiplas plataformas, facilidade de manutenção e isolamento de responsabilidades por funcionalidade.
- **Negativas:** Necessidade de manter bindings nativos para plugins específicos quando necessário.
