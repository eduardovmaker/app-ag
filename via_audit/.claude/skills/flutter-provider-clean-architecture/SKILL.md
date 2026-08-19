---
name: flutter-provider-clean-architecture
description: Perícia sobre a arquitetura Flutter do projeto: Clean Architecture por features, estado reativo com Provider (AuditProvider), roteamento com GoRouter e componentes visuais reutilizáveis (Mp*). Carregue ao criar ou alterar telas e componentes no app.
gerada-de: [specs/discovery/ARQUITETURA.md, specs/discovery/REQUISITOS.md]
atualizado-em: 2026-08-06
---

# Skill — Flutter Clean Architecture & Provider

> Skill sob medida deste projeto, gerada pelo `@agente-gerador-skills` a partir do discovery de **Via Audit**.
> Concentra os padrões arquiteturais de código e componentes visuais do projeto Flutter.

## Escopo e gatilhos
- **Cobre:** Organização de diretórios em `lib/features/`, desacoplamento de telas e componentes reutilizáveis `MpCard`, `MpButton`, `MpBadge`, `MpProgressBar`, `MpKpiCard`, `MpChecklistItem`, `MpActionButton`.
- **Carregue quando:** Criar novas rotas, refatorar widgets de tela ou adicionar novos componentes em `lib/core/widgets/`.
- **Não cobre:** Backend ou serviços de nuvem externos.

## Entidades e contratos
| Entidade | Onde (contrato/path) | Papel no recorte |
|----------|----------------------|------------------|
| `ViaAuditApp` | `lib/app/app.dart` | Raiz do aplicativo Flutter |
| `appRouter` | `lib/app/routes.dart` | Mapeamento declarativo de rotas |
| `AppTheme` / `AppColors` | `lib/core/theme/` | Design system com tema visual do app |

## Regras e invariantes deste recorte
- **Componentes do Core:** Reutilizar sempre que possível os widgets prefixados com `Mp` para manter consistência visual.
- **Proibição de `print`:** Nunca utilizar chamadas brutas a `print()` em arquivos de produção (`lib/`).

## Gates de controle humano aplicáveis (config seção 8)
- nenhum

## Armadilhas conhecidas → padrão do projeto
| Armadilha | Por que morde | Padrão correto aqui |
|-----------|---------------|---------------------|
| Instanciar estado local em widgets sem Provider | Desincroniza a árvore de widgets | Usar `context.read<AuditProvider>()` ou `context.watch<AuditProvider>()` |

## Referências
- Discovery: `specs/discovery/ARQUITETURA.md`, `specs/discovery/REQUISITOS.md`
- ADRs relacionados: `ADR-2026-0001`, `ADR-2026-0002`
