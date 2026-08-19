# CLAUDE.md — Diretrizes do Projeto Via Audit

## Spec-Driven Development (SDD Kit)

Este projeto utiliza o **SDD Kit** para gestão de especificações, arquitetura e qualidade de código.

- **Configuração do Projeto:** `sdd.config.md`
- **Especificações de Discovery (Engenharia Reversa):** `specs/discovery/`
- **Decisões de Arquitetura (ADRs):** `specs/decisions/`
- **Comando de Lint do SDD:** `node scripts/sdd-lint.mjs`

## Status do Módulo (Via-Audit)

| Spec | Título | Status | Testes |
|---|---|---|---|
| `SPEC-2026-010` | Autenticação por PIN de 4 Dígitos | `implementada` | 2 passando |
| `SPEC-2026-020` | Gestão e Listagem de Escolas | `implementada` | 1 passando |
| `SPEC-2026-030` | Checklist e Conferência de Ativos | `implementada` | 1 passando |
| `SPEC-2026-040` | Registro de Ativo e Evidência Fotográfica | `implementada` | 1 passando |
| `SPEC-2026-050` | Resumo da Visita e Assinatura do Diretor | `implementada` | 1 passando |

## Discovery (documentado por engenharia reversa)
- **Visão:** `specs/discovery/VISAO.md`
- **Requisitos:** `specs/discovery/REQUISITOS.md`
- **Fluxos:** `specs/discovery/FLUXOS.md`
- **Modelo de Dados:** `specs/discovery/MODELO-DADOS.md`
- **Arquitetura:** `specs/discovery/ARQUITETURA.md`
- **API:** `specs/discovery/API.md`
- **RBAC:** `specs/discovery/RBAC.md`
- **Backlog:** `specs/discovery/BACKLOG.md`
- **Infraestrutura:** `specs/discovery/INFRA.md`
- **Divergências e Lacunas:** `specs/discovery/AUDITORIA-DIVERGENCIAS.md`

## Comandos Principais
- **Rodar os testes:** `flutter test`
- **Análise estática:** `flutter analyze`
- **Validar SDD Kit:** `node scripts/sdd-lint.mjs`
