import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StatusSelectorWidget extends StatelessWidget {
  final String selectedStatus; // 'ok', 'avariado', 'nao_encontrado', 'extra'
  final Function(String) onStatusSelected;

  const StatusSelectorWidget({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  Widget _buildStatusBtn(String statusKey, String label, IconData icon, Color activeColor) {
    final isSelected = selectedStatus == statusKey;

    return InkWell(
      onTap: () => onStatusSelected(statusKey),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x040F172A),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? activeColor : AppColors.textSecondary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status do Item',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildStatusBtn('ok', 'OK', Icons.check_circle_outline, AppColors.success)),
            const SizedBox(width: 10),
            Expanded(child: _buildStatusBtn('avariado', 'Avariado', Icons.warning_amber_outlined, AppColors.warning)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildStatusBtn('nao_encontrado', 'Não Achei', Icons.highlight_off_outlined, AppColors.danger)),
            const SizedBox(width: 10),
            Expanded(child: _buildStatusBtn('extra', 'Extra', Icons.add_circle_outline, AppColors.secondary)),
          ],
        ),
      ],
    );
  }
}
