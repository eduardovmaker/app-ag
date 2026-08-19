import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/models/escola_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/escola_service.dart';
import '../../core/services/sync_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/escola_card_widget.dart';
import 'widgets/progresso_header_widget.dart';

class ListaEscolasScreen extends StatefulWidget {
  const ListaEscolasScreen({super.key});

  @override
  State<ListaEscolasScreen> createState() => _ListaEscolasScreenState();
}

class _ListaEscolasScreenState extends State<ListaEscolasScreen> {
  final EscolaService _escolaService = EscolaService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool _isOffline = false;
  String _orientadorNome = 'Orientador';
  int _orientadorId = 5;
  int _total = 0;
  int _visitadas = 0;
  List<EscolaModel> _escolas = [];
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _obterLocalizacao();
  }

  Future<void> _obterLocalizacao() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPosition = pos;
        });
        _calcularDistancias();
      }
    } catch (e) {
      debugPrint('Erro ao obter GPS: $e');
    }
  }

  void _calcularDistancias() {
    if (_currentPosition == null || _escolas.isEmpty) return;
    for (var e in _escolas) {
      if (e.lat != null && e.lng != null) {
        final meters = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          e.lat!,
          e.lng!,
        );
        e.distanciaKm = meters / 1000;
      }
    }
    setState(() {});
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
    });

    final savedId = await _authService.getSavedOrientadorId();
    if (savedId != null) {
      _orientadorId = int.parse(savedId);
    }
    final savedNome = await _authService.getSavedOrientadorNome();
    if (savedNome != null) {
      _orientadorNome = savedNome;
    }

    final data = await _escolaService.obterEscolas(_orientadorId);

    if (mounted) {
      setState(() {
        _isOffline = data['isOffline'] ?? false;
        if (data['orientador'] != null) {
          _orientadorNome = data['orientador']['nome'] ?? _orientadorNome;
        }
        _escolas = (data['escolas'] as List<EscolaModel>?) ?? [];
        _total = _escolas.length;
        _visitadas = _escolas.where((e) => e.status == 'concluida').length;
        _isLoading = false;
      });
      _calcularDistancias();
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente encerrar a sessão?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sair', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncService = context.watch<SyncService>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Escolas Designadas',
          style: AppTextStyles.sans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (syncService.pendingCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                avatar: const Icon(Icons.sync, size: 14, color: Colors.blue),
                label: Text('${syncService.pendingCount}', style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.blue.shade50,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProgressoHeaderWidget(
                      orientadorNome: _orientadorNome,
                      totalEscolas: _total,
                      escolasVisitadas: _visitadas,
                      semanaAtual: 3,
                      totalSemanas: 8,
                      isOffline: _isOffline,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Lista de Visitas',
                      style: AppTextStyles.sans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._escolas.map((escola) {
                      return EscolaCardWidget(
                        escola: escola,
                        onTap: () async {
                          if (escola.status == 'concluida') {
                            await context.push('/summary', extra: {'escolaId': escola.id, 'escolaNome': escola.nome});
                          } else {
                            await context.push('/checklist', extra: {'escolaId': escola.id, 'escolaNome': escola.nome});
                          }
                          if (mounted) _carregarDados();
                        },
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }
}
