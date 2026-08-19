---
doc-id: REQUISITOS
titulo: Requisitos Funcionais e Não-Funcionais — Via Audit
versao: 1.0.0
status: aprovada
atualizado-em: 2026-08-06
tipo: discovery
tags: [discovery, requisitos]
---

# Requisitos

## Requisitos Funcionais (RF) `[código]`

- **RF-01 (Autenticação):** O aplicativo deve permitir o login do auditor via credenciais de acesso (`/login`).
- **RF-02 (Listagem de Escolas):** O auditor deve visualizar as escolas agendadas, pendentes e concluídas com distância estimada e progresso de visita (`/schools`).
- **RF-03 (Checklist de Ativos):** O auditor deve ter acesso à lista de itens em comodato de uma escola selecionada (`/checklist`).
- **RF-04 (Conferência de Ativo):** O auditor pode alterar o status de conferência de um ativo entre `done` (ok), `warn` (avaria), `miss` (faltante), `extra` (excedente) ou `pending` (`/item-register`).
- **RF-05 (Registro de Patrimônio e Mídia):** O auditor pode ler/digitar o número de patrimônio e capturar foto do equipamento (`/item-register`).
- **RF-06 (Resumo da Visita):** Apresentar KPIs consolidando itens auditados, conformes, danificados e faltantes (`/visit-summary`).
- **RF-07 (Assinatura Digital):** Permitir a coleta da assinatura do responsável da escola na tela de resumo antes de finalizar a auditoria (`/visit-summary`).

## Requisitos Não-Funcionais (RNF) `[código]` / `[inferido]`

- **RNF-01 (Offline-First):** O aplicativo deve manter a funcionalidade de auditoria mesmo em locais sem sinal de internet, usando banco de dados local SQLite (`sqflite`).
- **RNF-02 (Sincronização):** Monitorar conectividade (`connectivity_plus`) e sincronizar dados com a retaguarda (`dio`) assim que houver conexão.
- **RNF-03 (Geolocalização):** Obter coordenadas GPS (`geolocator`) para comprovação da presença física do auditor na escola.
- **RNF-04 (Desempenho & UI):** Interface moderna e responsiva desenvolvida em Flutter 3 com Material Design 3 e suporte a tipografia `google_fonts`.
