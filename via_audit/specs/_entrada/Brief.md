# Brief — Via-Audit (Auditoria de Ativos Educacionais)

## 1. Nome e objetivo
- Via-Audit — auditoria de ativos dos colégios da Via Educat.

## 2. Problema/motivação
- Os ativos dos colégios estão inconsistentes dentro do ERP TOTVS Protheus, e precisamos realizar a auditoria de campo para identificar, conferir e corrigir todos os ativos em comodato que estão desatualizados no ERP.

## 3. Papéis/usuários
- **Orientadores Educacionais / Auditores:** acessar via PIN, localizar suas escolas, iniciar as auditorias, conferir itens do checklist, registrar divergências com foto e coletar a assinatura do diretor.
- **Diretores:** revisar o resumo da auditoria e assinar o termo de responsabilidade dos ativos.

## 4. Entidades de domínio
- **Escolas:** escolas cadastradas no sistema com código, nome, endereço, região e status de visita.
- **Ativos:** equipamentos em comodato (notebooks, tablets, projetores, etc.) com patrimônio, série, descrição e status de conferência (`done`, `warn`, `miss`, `extra`).
- **Visita / Auditoria:** registro do progresso da auditoria, geolocalização GPS, fotos de evidência e assinatura digital.

## 5. Telas/fluxos
- Login com PIN (`/login`).
- Lista de escolas (`/schools`).
- Checklist de ativos da escola (`/checklist`).
- Registro de ativo e captura de foto (`/item-register`).
- Resumo da visita e coleta de assinatura do diretor (`/visit-summary`).

## 6. Regras de negócio críticas
- Login com PIN de 4 dígitos.
- Seleção e localização das escolas por região/status.
- Alteração de status dos ativos (`done`, `warn`, `miss`, `extra`).
- Obrigatoriedade de captura de foto para itens com avaria ou faltantes.
- Coleta obrigatória de assinatura digital do Diretor para fechamento da visita.

## 7. Gates de controle humano
- Confirmação visual e assinatura digital do Diretor da escola no termo de responsabilidade antes de finalizar a auditoria.

## 8. Critérios de aceitação
- CA-01: Autenticação por PIN de 4 dígitos valida o orientador/auditor e direciona para a lista de escolas.
- CA-02: Lista de escolas exibe indicadores de progresso da auditoria e permite busca por nome ou região.
- CA-03: Checklist de ativos exibe todos os equipamentos vinculados à escola selecionada.
- CA-04: Tela de registro de ativo permite alterar o status de conferência e anexar foto comprobatória.
- CA-05: Finalização da auditoria exige preenchimento da assinatura do diretor e confirmação do termo de responsabilidade.
- CA-06: Resumo da visita calcula consolidação de itens OK, danificados, faltantes e excedentes.

## Opcionais
- Operação offline-first com sincronização automática quando conectado à rede.
