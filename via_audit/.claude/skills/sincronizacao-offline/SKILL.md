---
name: sincronizacao-offline
description: Perícia de operação offline-first e sincronização de dados: persistência local SQLite (sqflite), verificação de rede (connectivity_plus) e sincronização HTTP (dio). Carregue ao mexer no banco de dados local, cliente HTTP ou mecanismo de sync.
gerada-de: [specs/discovery/ARQUITETURA.md, specs/discovery/API.md, specs/discovery/INFRA.md]
atualizado-em: 2026-08-06
---

# Skill — Sincronização Offline-First

> Skill sob medida deste projeto, gerada pelo `@agente-gerador-skills` a partir do discovery de **Via Audit**.
> Concentra a perícia de resiliência e operação contínua em locais com conectividade oscilante ou inexistente.

## Escopo e gatilhos
- **Cobre:** Armazenamento offline de vistorias em `sqflite`, listener de conectividade com `connectivity_plus` e sincronização via REST com `dio`.
- **Carregue quando:** Trabalhar em camadas de repositório local, modelos SQLite, adaptadores Dio ou sincronizadores em segundo plano.
- **Não cobre:** Regras de layout de tela ou componentes visuais de UI.

## Entidades e contratos
| Entidade | Onde (contrato/path) | Papel no recorte |
|----------|----------------------|------------------|
| Database SQLite | `sqflite` (camada de persistência local) | Garante armazenamento durável sem sinal de internet |
| Cliente HTTP Dio | `dio` (camada de rede) | Executa uploads e downloads de dados ao reconectar |

## Regras e invariantes deste recorte
- **Offline Garantido:** Toda alteração de estado da auditoria deve ser imediatamente persistida no banco SQLite local antes de tentar o envio online.
- **Retry e Fila:** Falhas de requisição HTTP não devem perder dados do auditor; mantêm o registro com flag de sincronização pendente.

## Gates de controle humano aplicáveis (config seção 8)
- nenhum

## Armadilhas conhecidas → padrão do projeto
| Armadilha | Por que morde | Padrão correto aqui |
|-----------|---------------|---------------------|
| Requisição síncrona sem checar conectividade | Trava a interface em locais sem sinal de celular | Ler `connectivity_plus` antes e falhar suavemente gravando em banco local |

## Referências
- Discovery: `specs/discovery/ARQUITETURA.md`, `specs/discovery/API.md`
- ADRs relacionados: `ADR-2026-0001`
