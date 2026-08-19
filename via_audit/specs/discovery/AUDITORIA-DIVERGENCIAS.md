---
doc-id: AUDITORIA-DIVERGENCIAS
titulo: Relatório de Divergências e Lacunas de Auditoria — Via Audit
versao: 1.0.0
status: aprovada
atualizado-em: 2026-08-06
tipo: discovery
tags: [discovery, auditoria]
---

# Relatório de Divergências e Lacunas `[código]`

## Divergências Código × Usuário
- Nenhuma divergência detectada (Engenharia reversa realizada diretamente a partir do código Flutter funcional existente).

## Lacunas `<TODO>`
- `<TODO>` **Backend Endpoints:** Mapear URLs exatas de produção da API REST da Via Educat.
- `<TODO>` **Formato de Token de Auth:** Confirmar se JWT ou OAuth2 será utilizado para autenticação do auditor.

## Dívidas Conhecidas
- **Testes de Unidade:** Cobertura inicial restrita ao `widget_test.dart`. Recomenda-se adicionar testes de unidade para o `AuditProvider`.
- **Validação de Invariantes:** Nenhuma violação grave encontrada (0 proibições detectadas).
