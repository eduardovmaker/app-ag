---
spec-id: SPEC-2026-040
titulo: Registro de Ativo e Captura de Evidência Fotográfica
versao: 1.0.0
status: implementada
autor: eduardo.martins@viaeducat.com.br
criado-em: 2026-08-06
atualizado-em: 2026-08-06
tipo: feature
cas: 3
depende-de: [SPEC-2026-030]
tags: [registro, foto, camera, evidencias]
---

# SPEC-2026-040: Registro de Ativo e Captura de Evidência Fotográfica

## 📌 Resumo Executivo

Formulário de detalhamento do ativo auditado com leitor/digitador de patrimônio, seletor de status (`Conferido`, `Avaria`, `Faltante`, `Excedente`), observações de campo e captura obrigatória de foto comprobatória para irregularidades.

## 🎯 Contexto e Motivação

- **Problema atual:** Falta de evidências visuais quando equipamentos encontram-se danificados ou ausentes na escola.
- **Por que agora:** Garantir valor jurídico e rastreabilidade nas auditorias de comodato.

## ✅ Objetivos

1. Capturar foto via câmera do dispositivo ou galeria com suporte a tag GPS.
2. Exigir foto obrigatoriamente se a situação for marcada como `Avaria` ou `Faltante`.

## 📋 Requisitos

### Funcionais
- **RF-01**: Seletor visual de status do ativo.
- **RF-02**: Widget de captura/preview de foto com marcação de GPS.
- **RF-03**: Campo de texto livre para observações do auditor.

## ✅ Critérios de Aceitação

- **CA-01**: Marcar status como `warn` (avaria) sem capturar foto exibe alerta impedindo salvar.
- **CA-02**: Tirar foto anexa o caminho da imagem ao registro do ativo.
- **CA-03**: Salvar o registro atualiza os dados na lista de ativos e retorna à tela de checklist.
