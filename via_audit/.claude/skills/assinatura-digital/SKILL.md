---
name: assinatura-digital
description: Perícia de coleta de assinatura digital do gestor escolar: captura em canvas touch, conversão para bytes PNG/JPEG e validação do encerramento da visita. Carregue ao modificar a tela de resumo de visita ou componente de captura de assinatura.
gerada-de: [specs/discovery/REQUISITOS.md, specs/discovery/FLUXOS.md]
atualizado-em: 2026-08-06
---

# Skill — Assinatura Digital

> Skill sob medida deste projeto, gerada pelo `@agente-gerador-skills` a partir do discovery de **Via Audit**.
> Concentra a perícia do fluxo de validação legal e formalização do encerramento da auditoria na escola.

## Escopo e gatilhos
- **Cobre:** Interação com o pacote `signature`, exportação de bytes de imagem e associação da assinatura à conclusão da visita.
- **Carregue quando:** Trabalhar na tela `/visit-summary`, componentes de captura touch ou regras de aceite de auditoria.
- **Não cobre:** Conferência física de equipamentos.

## Entidades e contratos
| Entidade | Onde (contrato/path) | Papel no recorte |
|----------|----------------------|------------------|
| `signatureBytes` | `lib/features/audit/providers/audit_provider.dart` | Armazena os bytes da assinatura do gestor escolar |
| `VisitSummaryScreen` | `lib/features/summary/screens/visit_summary_screen.dart` | Tela de exibição dos indicadores e coleta da assinatura |

## Regras e invariantes deste recorte
- **Invariante de Conclusão:** É estritamente proibido alterar o status da escola para `completed` sem que `signatureBytes` esteja preenchido.
- **LGPD e Sensibilidade:** A assinatura coletada é tratada como dado sensível e deve ser vinculada unicamente ao relatório da visita ativa.

## Gates de controle humano aplicáveis (config seção 8)
- nenhum

## Armadilhas conhecidas → padrão do projeto
| Armadilha | Por que morde | Padrão correto aqui |
|-----------|---------------|---------------------|
| Limpar assinatura e tentar concluir | Gera um envio sem termo assinado | Validar `signatureBytes != null` antes de chamar `completeVisit()` |

## Referências
- Discovery: `specs/discovery/REQUISITOS.md`, `specs/discovery/FLUXOS.md`
- ADRs relacionados: `ADR-2026-0002`
