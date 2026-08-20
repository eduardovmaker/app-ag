import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../db/local_db.dart';
import '../db/daos/escolas_dao.dart';
import '../db/daos/visitas_dao.dart';
import '../models/visita_model.dart';

class VisitaService {
  final _api = ApiClient().client;

  Future<int> iniciarVisita(int orientadorId, int escolaId) async {
    final db = await LocalDb.database;
    await EscolasDao(db).atualizarStatusEscola(escolaId, 'em_andamento');

    try {
      final response = await _api.post('/visitas/iniciar', data: {
        'orientadorId': orientadorId,
        'escolaId': escolaId,
      });
      if (response.data != null && response.data['success'] == true) {
        final visitaId = response.data['data']['visitaId'];
        await VisitasDao(db).salvarVisita(
          VisitaModel(
            id: visitaId,
            orientadorId: orientadorId,
            escolaId: escolaId,
            status: 'em_andamento',
            iniciadaEm: DateTime.now().toIso8601String(),
            sincronizado: true,
          ),
        );
        return visitaId;
      }
    } catch (e) {
      debugPrint('Erro ao iniciar visita na API: $e. Fallback local...');
    }

    final dao = VisitasDao(db);
    final existente = await dao.buscarEmAndamento(orientadorId, escolaId);
    if (existente != null) {
      return existente.id;
    }

    final id = await dao.salvarVisita(
      VisitaModel(
        id: DateTime.now().millisecondsSinceEpoch,
        orientadorId: orientadorId,
        escolaId: escolaId,
        status: 'em_andamento',
        iniciadaEm: DateTime.now().toIso8601String(),
        sincronizado: false,
      ),
    );
    return id;
  }

  Future<bool> concluirVisita({
    required int visitaId,
    int escolaId = 1,
    required File assinaturaFile,
    String? observacaoGeral,
  }) async {
    final db = await LocalDb.database;
    await EscolasDao(db).atualizarStatusEscola(escolaId, 'concluida');

    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    bool onlineSucesso = false;
    if (isOnline) {
      try {
        final formData = FormData.fromMap({
          'observacaoGeral': observacaoGeral ?? '',
          'escolaId': escolaId,
          'assinatura': await MultipartFile.fromFile(assinaturaFile.path),
        });

        final response = await _api.post('/visitas/$visitaId/concluir', data: formData);
        if (response.data != null && response.data['success'] == true) {
          onlineSucesso = true;
        }
      } catch (e) {
        debugPrint('Erro ao concluir visita online: $e. Persistindo localmente em SQLite...');
      }
    }

    // Salvar estado concluído no SQLite
    await VisitasDao(db).salvarVisita(
      VisitaModel(
        id: visitaId,
        orientadorId: 1,
        escolaId: escolaId,
        status: 'concluida',
        concluidaEm: DateTime.now().toIso8601String(),
        assinaturaPath: assinaturaFile.path,
        observacaoGeral: observacaoGeral,
        sincronizado: onlineSucesso,
      ),
    );

    return onlineSucesso;
  }
}
