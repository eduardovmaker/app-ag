import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthService _authService = AuthService();
  final _api = ApiClient().client;

  bool _isLoading = true;
  Map<String, dynamic>? _statsData;

  @override
  void initState() {
    super.initState();
    _carregarEstatisticasAdmin();
  }

  Future<void> _carregarEstatisticasAdmin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _api.get('/admin/stats');
      if (response.data != null && response.data['success'] == true) {
        setState(() {
          _statsData = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar estatísticas do admin: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportarRelatorio(String tipo) async {
    final String path = tipo == 'excel' ? '/admin/reports/excel' : '/admin/reports/pdf';
    final String extensao = tipo == 'excel' ? 'XLSX' : 'PDF';

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gerando e baixando Relatório Consolidado ($extensao)...'),
          backgroundColor: AppColors.primary,
        ),
      );

      final response = await _api.get(
        path,
        options: Options(responseType: ResponseType.bytes),
      );

      if (mounted && response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Relatório $extensao baixado com sucesso! (${response.data.length} bytes)'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar relatório $extensao: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      context.go('/login');
    }
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: Color(0x060F172A), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTextStyles.sans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.sans(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rg = _statsData?['resumoGeral'] ?? {};
    final List orientadores = _statsData?['desempenhoOrientadores'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.admin_panel_settings, color: Colors.purple, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Painel do Administrador',
              style: AppTextStyles.sans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarEstatisticasAdmin,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Admin Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.purple.shade700, Colors.indigo.shade800]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: Colors.white, size: 36),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Administrador Geral',
                                  style: AppTextStyles.sans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Acesso seguro autenticado por PIN Admin & Token JWT',
                                  style: AppTextStyles.sans(fontSize: 12, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // KPIs Globais - Linha 1
                    Row(
                      children: [
                        _buildKpiCard('Total Escolas', '${rg['totalEscolas'] ?? 229}', Icons.school_outlined, AppColors.primary),
                        const SizedBox(width: 12),
                        _buildKpiCard('Concluídas', '${rg['escolasConcluidas'] ?? 0} (${rg['progressoGeralPct'] ?? 0}%)', Icons.check_circle_outline, AppColors.success),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // KPIs Globais - Linha 2
                    Row(
                      children: [
                        _buildKpiCard('Equip. Auditados', '${rg['totalRegistros'] ?? 0}', Icons.inventory_2_outlined, Colors.indigo),
                        const SizedBox(width: 12),
                        _buildKpiCard('Avariados / Ausentes', '${(rg['totalAvariados'] ?? 0) + (rg['totalNaoEncontrados'] ?? 0)}', Icons.warning_amber_rounded, AppColors.warning),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Botões de Exportação de Relatórios
                    Text(
                      'Exportação de Relatórios',
                      style: AppTextStyles.sans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _exportarRelatorio('excel'),
                            icon: const Icon(Icons.table_chart_outlined, color: Colors.white),
                            label: const Text('Exportar Excel (.XLSX)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _exportarRelatorio('pdf'),
                            icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
                            label: const Text('Exportar PDF (.PDF)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Tabela de Orientadores
                    Text(
                      'Progresso por Orientador (${orientadores.length})',
                      style: AppTextStyles.sans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    ...orientadores.map((o) {
                      final double pct = ((o['progressoPct'] ?? 0) as num) / 100.0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  o['nome'] ?? '',
                                  style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                                Text(
                                  '${o['escolasConcluidas']}/${o['totalEscolas']} escolas (${o['progressoPct']}%)',
                                  style: AppTextStyles.sans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(pct == 1.0 ? AppColors.success : AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('🟢 ${o['itemsOk'] ?? 0} OK', style: const TextStyle(fontSize: 11, color: Colors.green)),
                                const SizedBox(width: 12),
                                Text('⚠️ ${o['itemsAvariados'] ?? 0} avariados', style: const TextStyle(fontSize: 11, color: Colors.orange)),
                                const SizedBox(width: 12),
                                Text('❌ ${o['itemsNaoEncontrados'] ?? 0} ausentes', style: const TextStyle(fontSize: 11, color: Colors.red)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }
}
