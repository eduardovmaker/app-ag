import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mp_action_button.dart';
import '../../../core/widgets/mp_badge.dart';
import '../../../core/widgets/mp_button.dart';
import '../../audit/providers/audit_provider.dart';

class ItemRegisterScreen extends StatefulWidget {
  const ItemRegisterScreen({super.key});

  @override
  State<ItemRegisterScreen> createState() => _ItemRegisterScreenState();
}

class _ItemRegisterScreenState extends State<ItemRegisterScreen> {
  late TextEditingController _patrimonioController;
  MpActionType _selectedAction = MpActionType.ok;

  @override
  void initState() {
    super.initState();
    final auditProvider = Provider.of<AuditProvider>(context, listen: false);
    _patrimonioController =
        TextEditingController(text: auditProvider.currentItem.patrimonio);

    // Map existing status to MpActionType
    final status = auditProvider.currentItem.status;
    if (status == 'miss') {
      _selectedAction = MpActionType.danger;
    } else if (status == 'warn') {
      _selectedAction = MpActionType.warn;
    } else if (status == 'extra') {
      _selectedAction = MpActionType.extra;
    } else {
      _selectedAction = MpActionType.ok;
    }
  }

  @override
  void dispose() {
    _patrimonioController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    final auditProvider = Provider.of<AuditProvider>(context, listen: false);
    String statusStr = 'done';
    switch (_selectedAction) {
      case MpActionType.ok:
        statusStr = 'done';
        break;
      case MpActionType.warn:
        statusStr = 'warn';
        break;
      case MpActionType.danger:
        statusStr = 'miss';
        break;
      case MpActionType.extra:
        statusStr = 'extra';
        break;
    }

    auditProvider.updateCurrentItemStatus(
      statusStr,
      patrimonio: _patrimonioController.text,
    );

    if (auditProvider.selectedItemIndex <
        auditProvider.checklistItems.length - 1) {
      auditProvider.advanceToNextItem();
      setState(() {
        _patrimonioController.text = auditProvider.currentItem.patrimonio;
        final nextStatus = auditProvider.currentItem.status;
        if (nextStatus == 'miss') {
          _selectedAction = MpActionType.danger;
        } else if (nextStatus == 'warn') {
          _selectedAction = MpActionType.warn;
        } else if (nextStatus == 'extra') {
          _selectedAction = MpActionType.extra;
        } else {
          _selectedAction = MpActionType.ok;
        }
      });
    } else {
      context.push('/visit-summary');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auditProvider = Provider.of<AuditProvider>(context);
    final item = auditProvider.currentItem;
    final totalItems = auditProvider.checklistItems.length;
    final currentIndex = auditProvider.selectedItemIndex + 1;
    final remaining = totalItems - auditProvider.totalChecked;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 10,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Voltar',
                            style: AppTextStyles.sans(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$currentIndex de $totalItems unidades',
                    style: AppTextStyles.sans(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  MpBadge(
                    label: '$remaining restantes',
                    type: MpBadgeType.pend,
                  ),
                ],
              ),
            ),

            // Content Scroll
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  // Product Title & Meta
                  Text(
                    item.name,
                    style: AppTextStyles.sans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Unidade #${item.unitNumber} · Doc ${item.docNumber}',
                    style: AppTextStyles.sans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Photo Area
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A5874), Color(0xFF2A3547)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                color: Colors.white.withValues(alpha: 0.15),
                                child: Text(
                                  'GPS ●',
                                  style: AppTextStyles.mono(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2x2 Grid of Action Buttons
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.1,
                    children: [
                      MpActionButton(
                        label: 'OK / Conforme',
                        icon: Icons.check_circle_outline_rounded,
                        type: MpActionType.ok,
                        isActive: _selectedAction == MpActionType.ok,
                        onTap: () {
                          setState(() => _selectedAction = MpActionType.ok);
                        },
                      ),
                      MpActionButton(
                        label: 'Avariado',
                        icon: Icons.warning_amber_rounded,
                        type: MpActionType.warn,
                        isActive: _selectedAction == MpActionType.warn,
                        onTap: () {
                          setState(() => _selectedAction = MpActionType.warn);
                        },
                      ),
                      MpActionButton(
                        label: 'Não encontrado',
                        icon: Icons.highlight_off_rounded,
                        type: MpActionType.danger,
                        isActive: _selectedAction == MpActionType.danger,
                        onTap: () {
                          setState(
                              () => _selectedAction = MpActionType.danger);
                        },
                      ),
                      MpActionButton(
                        label: 'Extra / Troca',
                        icon: Icons.add_circle_outline_rounded,
                        type: MpActionType.extra,
                        isActive: _selectedAction == MpActionType.extra,
                        onTap: () {
                          setState(() => _selectedAction = MpActionType.extra);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Campo patrimônio
                  Text(
                    'CÓDIGO DE PATRIMÔNIO',
                    style: AppTextStyles.mono(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: _patrimonioController,
                            style: AppTextStyles.mono(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'PAT-2024-XXXX',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Camera scan button
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.lightPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Validation hint
                  Text(
                    '✓ Patrimônio válido',
                    style: AppTextStyles.sans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Success Button "Salvar e próximo →"
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MpButton(
                label: 'Salvar e próximo →',
                variant: MpButtonVariant.success,
                onPressed: _saveAndNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
