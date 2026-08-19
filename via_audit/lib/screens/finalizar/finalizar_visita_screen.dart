import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/db/local_db.dart';
import '../../core/db/daos/escolas_dao.dart';
import '../../core/db/daos/registros_dao.dart';
import '../../core/services/visita_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/mp_button.dart';
import 'widgets/resumo_card_widget.dart';
import 'widgets/assinatura_widget.dart';

class FinalizarVisitaScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;
  const FinalizarVisitaScreen({super.key, this.extraData});

  @override
  State<FinalizarVisitaScreen> createState() => _FinalizarVisitaScreenState();
}

class _FinalizarVisitaScreenState extends State<FinalizarVisitaScreen> {
  final VisitaService _visitaService = VisitaService();
  final TextEditingController _obsGeralController = TextEditingController();
  final TextEditingController _nomeRespController = TextEditingController();

  File? _assinaturaFile;
  bool _isLoading = false;
  int _visitaId = 42;
  int _escolaId = 1;

  int _encontrados = 0;
  int _divergentes = 0;
  int _naoEncontrados = 0;
  int _extras = 0;

  @override
  void initState() {
    super.initState();
    if (widget.extraData != null) {
      _visitaId = widget.extraData!['visitaId'] ?? _visitaId;
      _escolaId = widget.extraData!['escolaId'] ?? _escolaId;
    }
    _carregarResumo();
  }

  Future<void> _carregarResumo() async {
    final db = await LocalDb.database;
    final regs = await RegistrosDao(db).listarTodos();

    int enc = 0;
    int div = 0;
    int naoEnc = 0;
    int ext = 0;

    for (var r in regs) {
      if (r.status == 'ok') {
        enc++;
      } else if (r.status == 'avariado') {
        div++;
      } else if (r.status == 'nao_encontrado') {
        naoEnc++;
      } else if (r.status == 'extra') {
        ext++;
      }
    }

    if (mounted) {
      setState(() {
        _encontrados = enc;
        _divergentes = div;
        _naoEncontrados = naoEnc;
        _extras = ext;
      });
    }
  }

  @override
  void dispose() {
    _obsGeralController.dispose();
    _nomeRespController.dispose();
    super.dispose();
  }

  Future<void> _sincronizarAgora() async {
    if (_assinaturaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Colete a assinatura do responsável antes de concluir.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final sucesso = await _visitaService.concluirVisita(
      visitaId: _visitaId,
      escolaId: _escolaId,
      assinaturaFile: _assinaturaFile!,
      observacaoGeral: _obsGeralController.text.trim(),
    );

    final db = await LocalDb.database;
    await EscolasDao(db).atualizarStatusEscola(_escolaId, 'concluida');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visita concluída e enviada com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/schools');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sem conexão com o servidor. Salvo offline no aparelho.'),
            backgroundColor: Colors.orange,
          ),
        );
        context.go('/schools');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Finalizar Visita',
          style: AppTextStyles.sans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visita Concluída',
                        style: AppTextStyles.sans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        'Confira o resumo antes de enviar',
                        style: AppTextStyles.sans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Resumo Consolidado
            ResumoCardWidget(
              encontrados: _encontrados,
              divergentes: _divergentes,
              naoEncontrados: _naoEncontrados,
              extras: _extras,
            ),
            const SizedBox(height: 20),

            // Campo Observação Geral
            TextField(
              controller: _obsGeralController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Observações Gerais da Visita (opcional)',
                hintText: 'Ex: Diretor ausente, assinou vice-diretor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Nome do Responsável
            TextField(
              controller: _nomeRespController,
              decoration: const InputDecoration(
                labelText: 'Nome do Responsável pela Escola',
                hintText: 'Ex: Prof. Roberto Santos',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Canvas de Assinatura
            AssinaturaWidget(
              onSignatureCaptured: (file) {
                _assinaturaFile = file;
              },
            ),
            const SizedBox(height: 28),

            // Botão Sincronizar Agora
            MpButton(
              text: 'Sincronizar Agora',
              onPressed: _sincronizarAgora,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 12),

            // Botão Salvar Offline
            Center(
              child: TextButton(
                onPressed: () async {
                  final db = await LocalDb.database;
                  await EscolasDao(db).atualizarStatusEscola(_escolaId, 'concluida');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Salvo offline. Será enviado automaticamente ao conectar.')),
                    );
                    context.go('/schools');
                  }
                },
                child: const Text(
                  'Salvar Offline e Enviar Depois',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
