import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../db/local_db.dart';
import '../db/daos/escolas_dao.dart';
import '../models/escola_model.dart';

class EscolaService {
  final _api = ApiClient().client;

  Future<Map<String, dynamic>> obterEscolas(int orientadorId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    final db = await LocalDb.database;
    final dao = EscolasDao(db);

    if (isOnline) {
      try {
        final response = await _api.get('/escolas', queryParameters: {'orientadorId': orientadorId});
        if (response.data != null && response.data['success'] == true) {
          final data = response.data['data'];
          final List list = data['escolas'] ?? [];
          final escolas = list.map((e) => EscolaModel.fromJson(e)).toList();

          // Salvar localmente no SQLite
          await dao.salvarEscolas(escolas);

          return {
            'isOffline': false,
            'orientador': data['orientador'],
            'resumo': data['resumo'],
            'escolas': escolas,
          };
        }
      } catch (e) {
        debugPrint('Erro ao buscar escolas online: $e');
      }
    }

    // Fallback Offline
    final escolasLocais = await dao.listarPorOrientador(orientadorId);
    final visitadas = escolasLocais.where((e) => e.status == 'concluida').length;

    return {
      'isOffline': true,
      'orientador': {'id': orientadorId, 'nome': 'Daniela Moreira'},
      'resumo': {'total': escolasLocais.length, 'visitadas': visitadas, 'semanaAtual': 3, 'totalSemanas': 8},
      'escolas': escolasLocais,
    };
  }
}
