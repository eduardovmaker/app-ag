---
doc-id: FLUXOS
titulo: Fluxos de Usuário — Via Audit
versao: 1.0.0
status: aprovada
atualizado-em: 2026-08-06
tipo: discovery
tags: [discovery, fluxos]
---

# Fluxos de Usuário `[código]`

```mermaid
flowchart TD
    A[Tela de Login /login] --> B[Seleção de Escola /schools]
    B --> C[Checklist da Escola /checklist]
    C --> D[Conferência do Item /item-register]
    D -->|Próximo / Confirmar| C
    C -->|Finalizar Checklist| E[Resumo da Visita /visit-summary]
    E -->|Coletar Assinatura| F[Assinatura do Responsável]
    F -->|Concluir Auditoria| B
```

## Fluxo Principal de Auditoria
1. **Login:** Auditor autentica no app (`LoginScreen`).
2. **Seleção:** Seleciona a escola agendada no mapa/lista (`SchoolListScreen`).
3. **Checklist:** Visualiza a lista de itens vinculados ao contrato de comodato (`ChecklistScreen`).
4. **Item:** Seleciona item, lê/insere o código de patrimônio, registra fotos/observações e define o status (`ItemRegisterScreen`).
5. **Encerramento:** Confere os indicadores da visita, coleta a assinatura na tela (`VisitSummaryScreen`) e conclui a visita.
