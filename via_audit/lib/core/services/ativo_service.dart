import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../db/local_db.dart';
import '../db/daos/ativos_dao.dart';
import '../models/ativo_model.dart';

class AtivoService {
  final _api = ApiClient().client;

  Future<Map<String, dynamic>> obterAtivos(int escolaId, int orientadorId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    final db = await LocalDb.database;
    final dao = AtivosDao(db);

    if (isOnline) {
      try {
        final response = await _api.get('/ativos', queryParameters: {
          'escolaId': escolaId,
          'orientadorId': orientadorId,
        });
        if (response.data != null && response.data['success'] == true) {
          final data = response.data['data'];
          final List list = data['ativos'] ?? [];
          final ativos = list.map((a) => AtivoModel.fromJson(a)).toList();

          await dao.salvarAtivos(ativos);

          return {
            'isOffline': false,
            'escola': data['escola'],
            'resumo': data['resumo'],
            'ativos': ativos,
          };
        }
      } catch (e) {
        debugPrint('Erro ao buscar ativos online: $e');
      }
    }

    // Fallback Offline
    final ativosLocais = await dao.listarPorEscola(escolaId);
    final totalItens = ativosLocais.fold<int>(0, (sum, a) => sum + a.quantidade);
    final conferidos = ativosLocais.fold<int>(0, (sum, a) => sum + a.unidadesRegistradas);

    return {
      'isOffline': true,
      'escola': {'id': escolaId, 'nome': 'Escola Local', 'codigo': 'LOCAL-001'},
      'resumo': {'totalItens': totalItens, 'conferidos': conferidos},
      'ativos': ativosLocais,
    };
  }

  Future<void> adicionarAtivoExtra(int escolaId, String descricao, int quantidade) async {
    final novoAtivo = AtivoModel(
      id: DateTime.now().millisecondsSinceEpoch,
      escolaId: escolaId,
      descricao: descricao,
      quantidade: quantidade,
      origem: 'extra',
      statusChecklist: 'pendente',
      unidadesRegistradas: 0,
    );

    final db = await LocalDb.database;
    await AtivosDao(db).salvarAtivo(novoAtivo);
  }
}
