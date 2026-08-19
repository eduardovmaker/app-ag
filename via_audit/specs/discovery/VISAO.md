---
doc-id: VISAO
titulo: Visão do Produto — Via Audit
versao: 1.0.0
status: aprovada
atualizado-em: 2026-08-06
tipo: discovery
tags: [discovery, visao, produto]
---

# Visão do Produto — Via Audit

## 1. Problema e Oportunidade `[inferido]`
A **Via Educat** fornece equipamentos tecnológicos (Chromebooks, projetores, kits de robótica, redes) via comodato para instituições de ensino. A gestão de auditorias presenciais para conferência de patrimônio e estado de conservação requer um processo ágil, confiável e operável mesmo sem conectividade em campo.

## 2. Proposta de Valor `[código]`
O **Via Audit** é um aplicativo mobile que permite aos auditores de campo realizar auditorias físicas de patrimônio em escolas parceiras com:
- Validação rápida de checklist por equipamento.
- Leitura de plaquetas de patrimônio e captura de fotos de avaria.
- Geolocalização e coleta de assinatura digital do gestor escolar.
- Suporte a operação offline com sincronização posterior.

## 3. Personas Principais `[código]` / `[inferido]`
- **Auditor de Campo:** Profissional responsável por visitar as escolas, verificar cada ativo no local, registrar discrepâncias e colher a assinatura de encerramento da visita.
- **Gestor Escolar (Signatário):** Responsável da instituição que valida o resumo dos itens conferidos e assina o termo no dispositivo.
- **Administrador / Gestor de Comodato:** <TODO: Definir perfis do painel web de retaguarda>.

## 4. Escopo do MVP `[código]`
- [x] Autenticação simples de auditor (`/login`).
- [x] Seleção de escola na lista de agendamentos (`/schools`).
- [x] Checklist de equipamentos por escola (`/checklist`).
- [x] Registro/conferência de item individual (`/item-register`).
- [x] Resumo de visita com KPI de conferência e Coleta de Assinatura (`/visit-summary`).
