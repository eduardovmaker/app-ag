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

  Future<void> _abrirSeletorEscolasParaGerenciamentoAtivos() async {
    final List escolasList = _statsData?['escolas'] ?? [];

    if (escolasList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma escola encontrada para gerenciar.')),
      );
      return;
    }

    String busca = '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final escolasFiltradas = escolasList.where((e) {
              final nome = (e['nome'] ?? '').toString().toLowerCase();
              return nome.contains(busca.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Selecione uma Escola para Gerenciar Ativos',
                    style: AppTextStyles.sans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar escola por nome...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        busca = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: escolasFiltradas.length,
                      itemBuilder: (context, idx) {
                        final esc = escolasFiltradas[idx];
                        return ListTile(
                          title: Text(
                            esc['nome'] ?? '',
                            style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          subtitle: Text('Código: ${esc['codigo'] ?? 'N/A'} · ID: ${esc['id']}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                          onTap: () {
                            Navigator.pop(ctx);
                            _exibirModalGerenciamentoAtivos(esc['id'], esc['nome'] ?? '');
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _exibirModalGerenciamentoAtivos(int escolaId, String escolaNome) async {
    List ativosList = [];
    bool carregandoAtivos = true;

    Future<void> carregarAtivosAdmin() async {
      try {
        final res = await _api.get('/admin/escolas/$escolaId/ativos');
        if (res.data != null && res.data['success'] == true) {
          ativosList = res.data['data']['ativos'] ?? [];
        }
      } catch (e) {
        debugPrint('Erro ao carregar ativos para admin: $e');
      } finally {
        carregandoAtivos = false;
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (carregandoAtivos) {
              carregarAtivosAdmin().then((_) {
                setModalState(() {});
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Configurar Ativos Auditáveis',
                    style: AppTextStyles.sans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    escolaNome,
                    style: AppTextStyles.sans(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  if (!carregandoAtivos)
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                          onPressed: () async {
                            await _api.put('/admin/escolas/$escolaId/ativos/bulk-toggle', data: {'is_auditavel': 1});
                            setModalState(() {
                              carregandoAtivos = true;
                            });
                          },
                          icon: const Icon(Icons.check_box, color: Colors.white, size: 18),
                          label: const Text('Marcar Todos', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                          onPressed: () async {
                            await _api.put('/admin/escolas/$escolaId/ativos/bulk-toggle', data: {'is_auditavel': 0});
                            setModalState(() {
                              carregandoAtivos = true;
                            });
                          },
                          icon: const Icon(Icons.check_box_outline_blank, color: Colors.white, size: 18),
                          label: const Text('Desmarcar Todos', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: carregandoAtivos
                        ? const Center(child: CircularProgressIndicator())
                        : ativosList.isEmpty
                            ? const Center(child: Text('Nenhum ativo encontrado para esta escola.'))
                            : ListView.builder(
                                itemCount: ativosList.length,
                                itemBuilder: (context, idx) {
                                  final at = ativosList[idx];
                                  final bool isAuditavel = (at['is_auditavel'] as num?)?.toInt() == 1;

                                  return Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(color: isAuditavel ? Colors.green.shade300 : Colors.grey.shade300),
                                    ),
                                    color: isAuditavel ? Colors.green.shade50 : Colors.grey.shade50,
                                    child: SwitchListTile(
                                      activeThumbColor: Colors.green.shade700,
                                      value: isAuditavel,
                                      title: Text(
                                        at['descricao'] ?? '',
                                        style: AppTextStyles.sans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isAuditavel ? AppColors.textPrimary : Colors.grey.shade600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Qtd: ${at['quantidade']} · NF: ${at['nf'] ?? 'S/N'} ${isAuditavel ? '· [Aparece na Auditoria]' : '· [OCULTO para o orientador]'}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isAuditavel ? Colors.green.shade800 : Colors.grey.shade600,
                                        ),
                                      ),
                                      onChanged: (bool newVal) async {
                                        setModalState(() {
                                          at['is_auditavel'] = newVal ? 1 : 0;
                                        });
                                        await _api.patch('/admin/ativos/${at['id']}/toggle-auditavel', data: {'is_auditavel': newVal ? 1 : 0});
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

    final int totalEscolas = (rg['totalEscolas'] as num?)?.toInt() ?? 229;
    final int escolasConcluidas = (rg['escolasConcluidas'] as num?)?.toInt() ?? 0;
    final int progressoGeralPct = (rg['progressoGeralPct'] as num?)?.toInt() ?? 0;
    final int totalRegistros = (rg['totalRegistros'] as num?)?.toInt() ?? 0;
    final int totalAvariados = (rg['totalAvariados'] as num?)?.toInt() ?? 0;
    final int totalNaoEncontrados = (rg['totalNaoEncontrados'] as num?)?.toInt() ?? 0;

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
                        _buildKpiCard('Total Escolas', '$totalEscolas', Icons.school_outlined, AppColors.primary),
                        const SizedBox(width: 12),
                        _buildKpiCard('Concluídas', '$escolasConcluidas ($progressoGeralPct%)', Icons.check_circle_outline, AppColors.success),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // KPIs Globais - Linha 2
                    Row(
                      children: [
                        _buildKpiCard('Equip. Auditados', '$totalRegistros', Icons.inventory_2_outlined, Colors.indigo),
                        const SizedBox(width: 12),
                        _buildKpiCard('Avariados / Ausentes', '${totalAvariados + totalNaoEncontrados}', Icons.warning_amber_rounded, AppColors.warning),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Botões de Exportação de Relatórios
                    Text(
                      'Gestão & Relatórios Admin',
                      style: AppTextStyles.sans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _abrirSeletorEscolasParaGerenciamentoAtivos,
                      icon: const Icon(Icons.playlist_add_check_circle_outlined, color: Colors.white, size: 24),
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('⚙️ Flagar / Configurar Ativos Auditáveis por Escola', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
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
