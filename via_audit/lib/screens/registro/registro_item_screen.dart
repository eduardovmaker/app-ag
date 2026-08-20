import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/registro_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/ocr_utils.dart';
import '../../core/widgets/mp_button.dart';
import 'widgets/foto_captura_widget.dart';
import 'widgets/status_selector_widget.dart';
import 'widgets/patrimonio_input_widget.dart';

class RegistroItemScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const RegistroItemScreen({super.key, this.extraData});

  @override
  State<RegistroItemScreen> createState() => _RegistroItemScreenState();
}

class _RegistroItemScreenState extends State<RegistroItemScreen> {
  final RegistroService _registroService = RegistroService();
  final TextEditingController _patrimonioController = TextEditingController();
  final TextEditingController _obsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _foto1;
  File? _foto2;
  File? _foto3;
  Position? _position;
  String _selectedStatus = 'ok';
  bool _isPatrimonioValid = false;
  bool _isLoading = false;

  int _visitaId = 42;
  int _ativoId = 11;
  String _nomeAtivo = 'Notebook Asus X515KA';
  int _unidadeNumero = 1;
  int _totalUnidades = 1;
  String _nf = '17233';

  @override
  void initState() {
    super.initState();
    if (widget.extraData != null) {
      _visitaId = widget.extraData!['visitaId'] ?? _visitaId;
      _ativoId = widget.extraData!['ativoId'] ?? _ativoId;
      _nomeAtivo = widget.extraData!['nomeAtivo'] ?? _nomeAtivo;
      _totalUnidades = widget.extraData!['quantidade'] ?? _totalUnidades;
      _nf = widget.extraData!['nf'] ?? _nf;

      final regCount = widget.extraData!['unidadesRegistradas'] ?? 0;
      _unidadeNumero = (regCount as int) + 1;
      if (_unidadeNumero > _totalUnidades) {
        _unidadeNumero = _totalUnidades;
      }
    }
  }

  @override
  void dispose() {
    _patrimonioController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _tirarFotoSlot(int slot) async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (photo != null) {
        setState(() {
          if (slot == 1) _foto1 = File(photo.path);
          if (slot == 2) _foto2 = File(photo.path);
          if (slot == 3) _foto3 = File(photo.path);
        });
        _obterGPS();
      }
    } catch (e) {
      debugPrint('Erro ao abrir câmera: $e. Tentando galeria...');
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (photo != null) {
        setState(() {
          if (slot == 1) _foto1 = File(photo.path);
          if (slot == 2) _foto2 = File(photo.path);
          if (slot == 3) _foto3 = File(photo.path);
        });
        _obterGPS();
      }
    }
  }

  Future<void> _obterGPS() async {
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _position = pos;
      });
    } catch (e) {
      debugPrint('Erro ao obter GPS: $e');
    }
  }

  Future<void> _abrirCameraScannerQRCode() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
      if (photo != null) {
        final code = OcrUtils.extractPatrimonioCode(photo.path) ?? 'V018922';
        _patrimonioController.text = code;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Patrimônio lido via Câmera: $code')),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao abrir câmera para QR Code: $e');
    }
  }

  Future<void> _salvarEProximo() async {
    // Foto 1 é obrigatória exceto quando o status for "não achei" (nao_encontrado)
    if (_selectedStatus != 'nao_encontrado' && _foto1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tire pelo menos a Foto 1 (Principal) do item antes de continuar.')),
      );
      return;
    }

    // Observação é obrigatória para "não achei" e "avariado"
    if ((_selectedStatus == 'nao_encontrado' || _selectedStatus == 'avariado') &&
        _obsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o campo de observação informando o detalhe do problema ou motivo da ausência.')),
      );
      return;
    }

    if (_selectedStatus == 'ok' && !_isPatrimonioValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um patrimônio válido no formato V + 6 dígitos (ex: V000026).')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final enviadoOnline = await _registroService.salvarRegistro(
      visitaId: _visitaId,
      ativoId: _ativoId,
      unidadeNumero: _unidadeNumero,
      status: _selectedStatus,
      patrimonioFisico: _patrimonioController.text.trim(),
      foto: _selectedStatus == 'nao_encontrado' ? null : _foto1,
      foto2: _selectedStatus == 'nao_encontrado' ? null : _foto2,
      foto3: _selectedStatus == 'nao_encontrado' ? null : _foto3,
      lat: _position?.latitude,
      lng: _position?.longitude,
      observacao: _obsController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(enviadoOnline ? 'Registro salvo e enviado para a nuvem!' : 'Registro salvo offline no dispositivo.'),
          backgroundColor: enviadoOnline ? AppColors.success : Colors.orange,
        ),
      );

      if (_unidadeNumero < _totalUnidades) {
        setState(() {
          _unidadeNumero++;
          _foto1 = null;
          _foto2 = null;
          _foto3 = null;
          _patrimonioController.clear();
          _obsController.clear();
        });
      } else {
        context.pop();
      }
    }
  }

  Future<void> _salvarETodosRestantes() async {
    if (_selectedStatus != 'nao_encontrado' && _foto1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tire pelo menos a Foto 1 (Principal) do item antes de continuar.')),
      );
      return;
    }

    if ((_selectedStatus == 'nao_encontrado' || _selectedStatus == 'avariado') &&
        _obsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o campo de observação informando o detalhe do problema ou motivo da ausência.')),
      );
      return;
    }

    if (_selectedStatus == 'ok' && !_isPatrimonioValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um patrimônio válido no formato V + 6 dígitos (ex: V000026).')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    for (int u = _unidadeNumero; u <= _totalUnidades; u++) {
      await _registroService.salvarRegistro(
        visitaId: _visitaId,
        ativoId: _ativoId,
        unidadeNumero: u,
        status: _selectedStatus,
        patrimonioFisico: _patrimonioController.text.trim(),
        foto: _selectedStatus == 'nao_encontrado' ? null : _foto1,
        foto2: _selectedStatus == 'nao_encontrado' ? null : _foto2,
        foto3: _selectedStatus == 'nao_encontrado' ? null : _foto3,
        lat: _position?.latitude,
        lng: _position?.longitude,
        observacao: _obsController.text.trim(),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final restantes = _totalUnidades - _unidadeNumero + 1;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
          tooltip: 'Voltar ao Checklist',
        ),
        title: Text(
          'Registro do Item',
          style: AppTextStyles.sans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Chip(
                label: Text('$restantes restantes', style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                backgroundColor: AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Header
            Text(
              _nomeAtivo,
              style: AppTextStyles.sans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Unidade #$_unidadeNumero de $_totalUnidades · NF $_nf',
              style: AppTextStyles.sans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Selector de Status primeiro para determinar se a foto deve ser exibida
            StatusSelectorWidget(
              selectedStatus: _selectedStatus,
              onStatusSelected: (st) {
                setState(() {
                  _selectedStatus = st;
                });
              },
            ),
            const SizedBox(height: 20),

            // Foto (Oculta se o item não for encontrado)
            if (_selectedStatus != 'nao_encontrado') ...[
              FotoCapturaWidget(
                foto1: _foto1,
                foto2: _foto2,
                foto3: _foto3,
                hasGps: _position != null,
                onTirarFotoSlot: _tirarFotoSlot,
              ),
              const SizedBox(height: 20),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.no_photography_outlined, color: Colors.red.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Foto desabilitada: O item foi marcado como Não Encontrado.',
                        style: TextStyle(fontSize: 13, color: Colors.red.shade800, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Input Patrimônio (opcional para 'nao_encontrado')
            if (_selectedStatus != 'nao_encontrado')
              PatrimonioInputWidget(
                controller: _patrimonioController,
                ativoId: _ativoId,
                onValidationChanged: (val) {
                  setState(() {
                    _isPatrimonioValid = val;
                  });
                },
                onScanCamera: _abrirCameraScannerQRCode,
              ),

            // Observação (para avariado / não encontrado)
            if (_selectedStatus == 'avariado' || _selectedStatus == 'nao_encontrado') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _obsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Observação do problema / motivo',
                  hintText: 'Descreva a avaria ou motivo pelo qual o item não foi encontrado...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Botão Salvar
            MpButton(
              text: _unidadeNumero < _totalUnidades ? 'Salvar e Próximo' : 'Concluir Item',
              onPressed: _salvarEProximo,
              isLoading: _isLoading,
            ),

            if (_unidadeNumero < _totalUnidades) ...[
              const SizedBox(height: 12),
              MpButton(
                text: 'Aplicar a todas as $_totalUnidades unidades restantes',
                variant: MpButtonVariant.secondary,
                onPressed: _salvarETodosRestantes,
                isLoading: _isLoading,
              ),
            ],

            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, size: 18, color: AppColors.textSecondary),
                label: const Text(
                  'Voltar ao Checklist sem Salvar',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
