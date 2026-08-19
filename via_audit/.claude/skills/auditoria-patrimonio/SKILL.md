---
name: auditoria-patrimonio
description: Perícia de auditoria de patrimônio de comodato: regras de conferência de equipamentos, validação de plaqueta patrimonial, registro de avarias/ausências e status de vistoria. Carregue ao trabalhar em qualquer spec que toque no registro, checklist ou conciliação de ativos.
gerada-de: [specs/discovery/MODELO-DADOS.md, specs/discovery/REQUISITOS.md, specs/discovery/FLUXOS.md]
atualizado-em: 2026-08-06
---

# Skill — Auditoria de Patrimônio

> Skill sob medida deste projeto, gerada pelo `@agente-gerador-skills` a partir do discovery de **Via Audit**.
> Concentra a perícia do fluxo de conferência de bens em comodato nas instituições de ensino.

## Escopo e gatilhos
- **Cobre:** Conferência individual e em lote de equipamentos, atualização de status (`done`, `warn`, `miss`, `extra`), associação de número de patrimônio e foto da avaria.
- **Carregue quando:** Trabalhar em telas de checklist, cadastro de item, alteração de status de patrimônio ou cálculo de totais auditados.
- **Não cobre:** Autenticação de auditor ou sincronização remota via HTTP.

## Entidades e contratos
| Entidade | Onde (contrato/path) | Papel no recorte |
|----------|----------------------|------------------|
| `AuditItem` | `lib/features/audit/providers/audit_provider.dart` | Representa o item patrimonial em conferência |
| `AuditProvider` | `lib/features/audit/providers/audit_provider.dart` | Gerencia a seleção e atualização de status do ativo |

## Regras e invariantes deste recorte
- **Transição de Status:** Itens em estado `pending` mudam para `active` ao serem selecionados para conferência.
- **Identificação Oblíqua:** Todo item finalizado com `done` ou `warn` deve obrigatoriamente possuir uma etiqueta de patrimônio preenchida.
- **Contagem de Danificados e Faltantes:** As métricas de avaria (`warn`) e ausência (`miss`) afetam diretamente o relatório do resumo da visita.

## Gates de controle humano aplicáveis (config seção 8)
- nenhum

## Armadilhas conhecidas → padrão do projeto
| Armadilha | Por que morde | Padrão correto aqui |
|-----------|---------------|---------------------|
| Mudar status sem notificar listeners | UI fica desalinhada do progresso real da escola | Sempre usar `updateCurrentItemStatus()` via `AuditProvider` |
| Sobra de itens pendentes ao finalizar | A visita pode ser marcada como concluída com itens sem vistoria | Verificar `visitedAssets` vs `totalAssets` na tela de resumo |

## Referências
- Discovery: `specs/discovery/MODELO-DADOS.md`, `specs/discovery/REQUISITOS.md`
- ADRs relacionados: `ADR-2026-0002`
