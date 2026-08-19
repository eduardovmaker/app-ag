import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/ativo_model.dart';
import '../../core/services/ativo_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/visita_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/mp_button.dart';
import 'widgets/ativo_checklist_item.dart';
import 'widgets/add_extra_bottom_sheet.dart';

class ChecklistEscolaScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;
  const ChecklistEscolaScreen({super.key, this.extraData});

  @override
  State<ChecklistEscolaScreen> createState() => _ChecklistEscolaScreenState();
}

class _ChecklistEscolaScreenState extends State<ChecklistEscolaScreen> {
  final AtivoService _ativoService = AtivoService();
  final VisitaService _visitaService = VisitaService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  String _escolaNome = 'Colégio Álamo Vinhedo';
  String _codigo = '023448';
  int _escolaId = 1;
  int _orientadorId = 5;
  int _totalItens = 9;
  int _conferidos = 5;
  int? _focusedAtivoId;
  List<AtivoModel> _ativos = [];

  @override
  void initState() {
    super.initState();
    if (widget.extraData != null) {
      _escolaId = widget.extraData!['escolaId'] ?? _escolaId;
      _escolaNome = widget.extraData!['escolaNome'] ?? _escolaNome;
    }
    _carregarAtivos();
  }

  Future<void> _carregarAtivos() async {
    setState(() {
      _isLoading = true;
    });

    final savedId = await _authService.getSavedOrientadorId();
    if (savedId != null) {
      _orientadorId = int.parse(savedId);
    }

    final data = await _ativoService.obterAtivos(_escolaId, _orientadorId);

    if (mounted) {
      setState(() {
        if (data['escola'] != null) {
          _escolaNome = data['escola']['nome'] ?? _escolaNome;
          _codigo = data['escola']['codigo'] ?? _codigo;
        }
        if (data['resumo'] != null) {
          _totalItens = data['resumo']['totalItens'] ?? 9;
          _conferidos = data['resumo']['conferidos'] ?? 5;
        }
        _ativos = data['ativos'] ?? [];
        _isLoading = false;
      });
    }
  }

  void _abrirAddExtra() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => AddExtraBottomSheet(
        onSave: (descricao, quantidade) async {
          await _ativoService.adicionarAtivoExtra(_escolaId, descricao, quantidade);
          _carregarAtivos();
        },
      ),
    );
  }

  Future<void> _iniciarVisitaENavegar(AtivoModel ativo) async {
    setState(() {
      _focusedAtivoId = ativo.id;
    });

    final visitaId = await _visitaService.iniciarVisita(_orientadorId, _escolaId);
    if (mounted) {
      await context.push('/item-register', extra: {
        'visitaId': visitaId,
        'ativoId': ativo.id,
        'nomeAtivo': ativo.descricao,
        'quantidade': ativo.quantidade,
        'unidadesRegistradas': ativo.unidadesRegistradas,
        'nf': ativo.nf ?? 'S/N',
      });
      _carregarAtivos();
    }
  }

  void _tentarFinalizar() {
    final temPendente = _ativos.any((a) => a.statusChecklist == 'pendente');
    if (temPendente) {
      final pendentesCount = _ativos.where((a) => a.statusChecklist == 'pendente').length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Você ainda possui $pendentesCount item(ns) pendente(s) de inspeção no checklist.',
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    context.push('/summary', extra: {
      'visitaId': 42,
      'escolaId': _escolaId,
    });
  }

  @override
  Widget build(BuildContext context) {
    final progresso = _totalItens > 0 ? _conferidos / _totalItens : 0.0;
    final bool temPendente = _ativos.any((a) => a.statusChecklist == 'pendente');
    final bool todosValidados = _ativos.isNotEmpty && !temPendente;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Checklist da Escola',
          style: AppTextStyles.sans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: _abrirAddExtra,
            tooltip: 'Adicionar Item Extra',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header Card
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _escolaNome,
                        style: AppTextStyles.sans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Código: $_codigo',
                        style: AppTextStyles.sans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_conferidos / $_totalItens itens conferidos',
                            style: AppTextStyles.sans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${(progresso * 100).toInt()}%',
                            style: AppTextStyles.sans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progresso,
                          minHeight: 8,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Lista de Ativos
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _ativos.length,
                    itemBuilder: (context, index) {
                      final ativo = _ativos[index];
                      return AtivoChecklistItem(
                        ativo: ativo,
                        isFocused: _focusedAtivoId == ativo.id,
                        onTap: () => _iniciarVisitaENavegar(ativo),
                      );
                    },
                  ),
                ),

                // Botão Continuar
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: MpButton(
                    text: todosValidados ? 'Continuar para Finalizar' : 'Pendente: $_conferidos/$_totalItens validados',
                    onPressed: _tentarFinalizar,
                  ),
                ),
              ],
            ),
    );
  }
}
