---
spec-id: SPEC-2026-030
titulo: Checklist e Conferência de Ativos
versao: 1.0.0
status: implementada
autor: eduardo.martins@viaeducat.com.br
criado-em: 2026-08-06
atualizado-em: 2026-08-06
tipo: feature
cas: 3
depende-de: [SPEC-2026-020]
tags: [checklist, ativos, conferencia]
---

# SPEC-2026-030: Checklist e Conferência de Ativos

## 📌 Resumo Executivo

Interface de conferência item a item dos ativos cadastrados no ERP TOTVS Protheus para a escola selecionada, exibindo patrimônio, número de série e permitindo marcar visualmente a situação de cada equipamento.

## 🎯 Contexto e Motivação

- **Problema atual:** Inconsistência nos cadastros do ERP exige verificação individual e presencial dos equipamentos.
- **Por que agora:** Núcleo principal da auditoria de campo.

## ✅ Objetivos

1. Apresentar a lista completa de ativos da escola selecionada.
2. Permitir alteração rápida de status de conferência.

## 📋 Requisitos

### Funcionais
- **RF-01**: Exibir itens ordenados por tipo/ambiente ou número de patrimônio.
- **RF-02**: Destacar visualmente o status atual (`done`, `warn`, `miss`, `extra`).
- **RF-03**: Exibir indicador de progresso total da escola na parte superior.

## ✅ Critérios de Aceitação

- **CA-01**: Tocar em um ativo da lista abre a tela de registro de detalhes e foto (`/item-register`).
- **CA-02**: Alterar o status de um ativo atualiza instantaneamente o progresso da auditoria na tela.
- **CA-03**: Filtro de ativos por status (Pendente vs. Auditado) permite focar nos itens restantes.
