import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../db/local_db.dart';
import '../db/daos/registros_dao.dart';

enum SyncStatus { idle, syncing, error, done }

class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;

  final _api = ApiClient().client;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;

  SyncStatus _status = SyncStatus.idle;
  int _pendingCount = 0;

  SyncStatus get status => _status;
  int get pendingCount => _pendingCount;

  SyncService._internal() {
    _initConnectivityListener();
    _startPeriodicRetry();
    atualizarContadorPendente();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        sincronizarPendentes();
      }
    });
  }

  void _startPeriodicRetry() {
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_pendingCount > 0 && _status != SyncStatus.syncing) {
        sincronizarPendentes();
      }
    });
  }

  Future<void> atualizarContadorPendente() async {
    try {
      final db = await LocalDb.database;
      final pendentes = await RegistrosDao(db).listarNaoSincronizados();
      _pendingCount = pendentes.length;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar contador pendente: $e');
    }
  }

  Future<void> sincronizarPendentes() async {
    if (_status == SyncStatus.syncing) return;

    try {
      final db = await LocalDb.database;
      final dao = RegistrosDao(db);
      final pendentes = await dao.listarNaoSincronizados();
      _pendingCount = pendentes.length;

      if (pendentes.isEmpty) {
        _status = SyncStatus.idle;
        notifyListeners();
        return;
      }

      _status = SyncStatus.syncing;
      notifyListeners();

      // Processar em lotes de até 10 registros
      const batchSize = 10;
      for (var i = 0; i < pendentes.length; i += batchSize) {
        final batch = pendentes.sublist(
          i,
          i + batchSize > pendentes.length ? pendentes.length : i + batchSize,
        );

        final payloadRegistros = [];
        for (var reg in batch) {
          String? base64Photo1;
          if (reg.fotoPath != null && File(reg.fotoPath!).existsSync()) {
            final bytes = await File(reg.fotoPath!).readAsBytes();
            base64Photo1 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
          }

          String? base64Photo2;
          if (reg.fotoPath2 != null && File(reg.fotoPath2!).existsSync()) {
            final bytes = await File(reg.fotoPath2!).readAsBytes();
            base64Photo2 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
          }

          String? base64Photo3;
          if (reg.fotoPath3 != null && File(reg.fotoPath3!).existsSync()) {
            final bytes = await File(reg.fotoPath3!).readAsBytes();
            base64Photo3 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
          }

          payloadRegistros.add({
            'localId': reg.id.toString(),
            'visitaId': reg.visitaId,
            'ativoId': reg.ativoId,
            'unidadeNumero': reg.unidadeNumero,
            'status': reg.status,
            'patrimonioFisico': reg.patrimonioFisico ?? '',
            'fotoBase64': base64Photo1,
            'fotoBase64_2': base64Photo2,
            'fotoBase64_3': base64Photo3,
            'lat': reg.lat,
            'lng': reg.lng,
            'observacao': reg.observacao ?? '',
            'criadoEm': reg.criadoEm,
          });
        }

        final response = await _api.post('/sync/upload', data: {
          'registros': payloadRegistros,
        });

        if (response.data != null && response.data['success'] == true) {
          for (var reg in batch) {
            if (reg.id != null) {
              await dao.marcarComoSincronizado(reg.id!);
            }
          }
        }
      }

      await atualizarContadorPendente();
      _status = _pendingCount == 0 ? SyncStatus.done : SyncStatus.idle;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro na sincronização offline: $e');
      _status = SyncStatus.error;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }
}
