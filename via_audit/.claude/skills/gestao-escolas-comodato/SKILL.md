---
name: gestao-escolas-comodato
description: Perícia de gestão de escolas em contrato de comodato: listagem de instituições agendadas, filtro por status da visita e acompanhamento do indicador de distância e progresso. Carregue ao implementar ou modificar o fluxo de seleção e acompanhamento de escolas.
gerada-de: [specs/discovery/MODELO-DADOS.md, specs/discovery/VISAO.md]
atualizado-em: 2026-08-06
---

# Skill — Gestão de Escolas em Comodato

> Skill sob medida deste projeto, gerada pelo `@agente-gerador-skills` a partir do discovery de **Via Audit**.
> Concentra a perícia de listagem e controle do ciclo de vida das visitas às instituições de ensino.

## Escopo e gatilhos
- **Cobre:** Lista de escolas agendadas, ordenação por proximidade, cálculo de ativos auditados por escola e atualização do status da visita (`scheduled`, `pending`, `completed`).
- **Carregue quando:** Trabalhar na tela `/schools`, seleção de local de trabalho ou dashboards de auditoria.
- **Não cobre:** Conferência detalhada de itens específicos.

## Entidades e contratos
| Entidade | Onde (contrato/path) | Papel no recorte |
|----------|----------------------|------------------|
| `AuditSchool` | `lib/features/audit/providers/audit_provider.dart` | Representa a instituição de ensino e o status da visita |
| `SchoolListScreen` | `lib/features/schools/screens/school_list_screen.dart` | Tela principal de listagem e navegação para checklist |

## Regras e invariantes deste recorte
- **Status da Visita:** Visitas iniciadas mudam para `pending` e somente transitam para `completed` quando a assinatura digital é colhida.
- **Indicador de Progresso:** `visitedAssets` deve refletir dinamicamente a contagem de itens auditados em relação a `totalAssets`.

## Gates de controle humano aplicáveis (config seção 8)
- nenhum

## Armadilhas conhecidas → padrão do projeto
| Armadilha | Por que morde | Padrão correto aqui |
|-----------|---------------|---------------------|
| Iniciar auditoria de escola não selecionada | Dados de ativos misturarem-se no provider | Invocar `selectSchool(index)` ao selecionar o card da escola |

## Referências
- Discovery: `specs/discovery/VISAO.md`, `specs/discovery/FLUXOS.md`
- ADRs relacionados: `ADR-2026-0001`
