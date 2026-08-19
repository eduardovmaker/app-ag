---
sdd-config-version: 1.0.0
projeto: Via Audit
atualizado-em: 2026-08-06
---

# sdd.config — Configuração do projeto para o SDD Kit

---

## 1. Identidade

- **Nome:** Via Audit
- **Tipo:** App Mobile (Flutter)
- **Domínio em uma frase:** Aplicativo mobile de auditoria de comodato de equipamentos educacionais da Via Educat.
- **Estágio:** MVP funcional (código frontend e estado reativo implementados)

---

## 2. Stack e comandos

| Item | Valor neste projeto |
|------|---------------------|
| Linguagem/framework principal | Flutter 3.12+ (Dart) |
| Biblioteca de UI | Material Design 3 via `lib/core/theme/` e `lib/core/widgets/` |
| Estado | Provider (`provider: ^6.1.2`) |
| Gerenciador de pacotes | flutter pub / pub |
| **Comando de testes (unit/componente)** | `flutter test` |
| **Comando de testes e2e** | `n/a` |
| **Comando de typecheck/lint** | `flutter analyze` |

---

## 3. Estrutura de pastas (paths)

| Artefato | Caminho neste projeto |
|----------|------------------------|
| Specs | `specs/` |
| Contratos/tipos compartilhados | `lib/features/audit/providers/audit_provider.dart` |
| Módulo de domínio | `lib/features/<modulo>/` |
| Mocks | `lib/features/audit/providers/audit_provider.dart` |
| Stores | `lib/features/audit/providers/audit_provider.dart` |
| Views/telas | `lib/features/<modulo>/screens/*.dart` |
| Rotas | `lib/app/routes.dart` |
| **Registro de navegação (menu)** | `lib/app/routes.dart` |
| Testes (colocação) | `test/` |
| Testes e2e | `n/a` |

### 3-B. Paths de backend (se houver servidor)

| Artefato | Caminho neste projeto |
|----------|------------------------|
| Raiz do backend | `n/a` |
| Handlers/controllers (borda) | `n/a` |
| Serviços (regra de negócio) | `n/a` |
| Repositórios (acesso a dados) | `n/a` |
| Migrations | `n/a` |
| Contrato de API (OpenAPI) | `specs/apis/openapi.yaml` |
| Testes de integração | `n/a` |

---

## 4. Numeração de specs

- **Prefixo:** `SPEC-2026-`
- **Incremento por submódulo:** `+10`
- **Bloco inicial:** auto

---

## 5. Camadas de implementação (pipeline)

| Ordem | Camada | Agente | Saída esperada |
|-------|--------|--------|----------------|
| 1 | Contratos/tipos | `@agente-arquiteto-contratos` | Modelos em `lib/features/audit/providers/` |
| 2 | Dados mockados | `@agente-mock-data` | Lista inicial em `AuditProvider` |
| 3 | Estado/store + invariantes | `@agente-frontend` | `AuditProvider` atualizando reativamente |
| 4 | UI + rotas + menu | `@agente-frontend` | Screens em `lib/features/` + `routes.dart` |
| 5 | Testes unit/componente | `@agente-qa-testes` | Testes em `test/` |
| 6 | Testes e2e | `@agente-e2e` | `n/a` |
| 7 | Guardião | `@agente-spec-guardian` | Conformidade da spec |

---

## 6. Regras inegociáveis (deste projeto)

1. **Spec-driven.** Todo trabalho deriva de uma spec em `specs/`. Sem spec → `/nova-spec` antes.
2. **Arquitetura limpa por features.** Manter widgets genéricos em `lib/core/widgets/` e telas em `lib/features/<modulo>/screens/`.
3. **Estado via Provider.** Não manipular estado global fora do `AuditProvider`.
4. **Respeito ao Design System.** Utilizar as cores de `AppColors` e estilos de `AppTextStyles`.

---

## 7. Padrões proibidos (grep de ausência)

| Padrão (regex) | Escopo (path) | Esperado |
|----------------|----------------|----------|
| `print\(` | `lib/` | 0 |

---

## 8. Gates de controle humano

| Decisão | Entidade | Setter único permitido | Invariante |
|---------|----------|------------------------|------------|
| nenhum | nenhum | nenhum | nenhum |

---

## 9. Tópicos bloqueados (pare e avise)

- nenhum

---

## 10. Defaults para o brief

| Campo opcional | Default deste projeto |
|----------------|------------------------|
| Multi-tenant/escopo | escopo por `schoolId` |
| Dados sensíveis/LGPD | Assinatura digital do responsável da escola é dado sensível |
| Não-objetivos | Sem suporte a multi-usuário simultâneo no mesmo aparelho |
| Restrições técnicas | Flutter 3.12+, suporte a Android, iOS e Windows |

---

## 11. Portões de engenharia (opcionais)

| Portão | Ativar? | Como / limite |
|--------|---------|---------------|
| Cobertura mínima de testes | `false` | `flutter test --coverage` |
| Auditoria de dependências | `false` | `flutter pub outdated` |
| Lint de segurança | `false` | `flutter analyze` |
| Migrations reversíveis | `false` | `n/a` |
| Conformidade de contrato (API) | `false` | `n/a` |

---

## 12. Design System (opcional)

- **ativo:** `false`

### 12.1 Identidade do DS
| Item | Valor |
|------|-------|
| Nome do design system | `n/a` |
| Nº aproximado de componentes | `n/a` |
| Framework | Flutter |
| Estilização | ThemeData |
| Suporta temas (multi-theme)? | false |
| Raiz dos tokens | `lib/core/theme/` |
| Raiz dos componentes do DS | `lib/core/widgets/` |

### 12.2 Calibração de severidade (findings das auditorias)

| Violação | Severidade |
|----------|------------|
| Cor hardcoded (`hardcoded_color`) | high |
| Espaçamento hardcoded (`hardcoded_spacing`) | medium |
| Tipografia hardcoded (`hardcoded_typography`) | medium |
| Referência de tier errada (`wrong_tier_reference`) | high |
| Estado de interação faltando (`missing_interaction_state`) | high |
| ARIA faltando (`missing_aria`) | critical |
| Violação de nomenclatura (`naming_violation`) | medium |
| Vazamento de tier (`tier_leakage`) | high |

### 12.3 Portões de release do DS (agente component-to-release)
| Portão | Bloqueia release? |
|--------|-------------------|
| Tier errado (`wrong_tier`) | true |
| Cor hardcoded | true |
| Teclado (acessibilidade) | true |
| Contraste | true |
| Divergência crítica design↔código | true |

### 12.4 Integrações (opcional — auto-pull de dados)

| Fonte | Ativa? | Referência |
|-------|--------|-----------|
| Figma | false | n/a |

### 12.5 Relatórios recorrentes
| Item | Valor |
|------|-------|
| Diretório de saída | `.ds-ops-reports/` |
| Padrão de nome | `{skill}-{date}` |
| Modo de comparação | summary |
| Quantos manter | 8 |
| Limite de doc obsoleta (dias) | 90 |
