---
spec-id: SPEC-2026-050
titulo: Resumo da Visita e Assinatura Digital do Diretor
versao: 1.0.0
status: implementada
autor: eduardo.martins@viaeducat.com.br
criado-em: 2026-08-06
atualizado-em: 2026-08-06
tipo: feature
cas: 3
depende-de: [SPEC-2026-030, SPEC-2026-040]
tags: [resumo, assinatura, diretor, termo]
---

# SPEC-2026-050: Resumo da Visita e Assinatura Digital do Diretor

## 📌 Resumo Executivo

Apresentar o relatório consolidado de auditoria da escola (total de equipamentos, conformes, danificados, ausentes), coletar o nome e a assinatura manuscrita digital do Diretor da escola no canvas, gerando o Termo de Responsabilidade e finalizando a visita.

## 🎯 Contexto e Motivação

- **Problema atual:** Falta de formalização da auditoria perante os diretores das escolas.
- **Por que agora:** Encerramento formal do processo de auditoria com validação legal/responsabilidade.

## ✅ Objetivos

1. Exibir KPIs consolidados da visita de auditoria.
2. Capturar a assinatura digital na tela e validar o encerramento da visita.

## 📋 Requisitos

### Funcionais
- **RF-01**: Apresentar estatísticas de encerramento da escola.
- **RF-02**: Campo para assinatura manuscrita (touch/stylus) no canvas.
- **RF-03**: Geração de termo com carimbo de data, hora e geolocalização.

## ✅ Critérios de Aceitação

- **CA-01**: Tentar finalizar a visita sem preencher a assinatura do diretor exibe mensagem de alerta.
- **CA-02**: Desenhar a assinatura e clicar em "Finalizar Auditoria" marca a escola como auditada (`done`).
- **CA-03**: Exibir o resumo completo dos itens divergentes para revisão do diretor antes de assinar.
