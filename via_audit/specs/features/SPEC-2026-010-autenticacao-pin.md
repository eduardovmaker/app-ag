---
spec-id: SPEC-2026-010
titulo: Autenticação por PIN de 4 Dígitos
versao: 1.0.0
status: implementada
autor: eduardo.martins@viaeducat.com.br
criado-em: 2026-08-06
atualizado-em: 2026-08-06
tipo: feature
cas: 3
depende-de: []
tags: [autenticacao, pin, seguranca]
---

# SPEC-2026-010: Autenticação por PIN de 4 Dígitos

## 📌 Resumo Executivo

Prover acesso rápido e seguro aos Orientadores Educacionais e Auditores de campo via teclado numérico dedicado (PIN de 4 dígitos), liberando a sessão e garantindo o fluxo de auditoria sem a necessidade de senhas complexas no dispositivo mobile.

## 🎯 Contexto e Motivação

- **Problema atual:** Auditores precisam acessar o app em campo de forma ágil sem digitar e-mails ou senhas longas.
- **Por que agora:** Essencial para garantir a segurança no acesso aos dados de escolas e ativos antes de iniciar auditorias.

## ✅ Objetivos

1. Validar PIN de 4 dígitos com feedback visual instantâneo.
2. Armazenar o estado da sessão de forma segura no app.

## ❌ Não-Objetivos

1. Autenticação biométrica nesta versão.
2. Recuperação de PIN via SMS.

## 📋 Requisitos

### Funcionais
- **RF-01**: Permitir a digitação sequencial de 4 números com máscara visual.
- **RF-02**: Validar o PIN contra a credencial cadastrada e redirecionar para `/schools`.
- **RF-03**: Exibir mensagem de erro clara em caso de PIN incorreto.

### Não-Funcionais
- **RNF-01**: Tempo de resposta de validação inferior a 200ms.

## 🏗️ Design Proposto

### Modelo de dados
```dart
class AuthState {
  final bool isAuthenticated;
  final String? auditorId;
  final String? error;
}
```

## ✅ Critérios de Aceitação

- **CA-01**: Inserir PIN válido (ex: `1234`) altera `isAuthenticated` para `true` e redireciona para a tela de escolas.
- **CA-02**: Inserir PIN inválido bloqueia a navegação e exibe a mensagem de erro "PIN incorreto".
- **CA-03**: Botão de apagar limpa o último dígito inserido na interface.

## ⚠️ Riscos e Mitigações

| Risco | Impacto | Mitigação |
|-------|---------|-----------|
| Tentativas de força bruta | Média | Bloqueio temporário após 5 tentativas incorretas |
