import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../db/local_db.dart';
import '../db/daos/registros_dao.dart';
import '../models/registro_model.dart';
import '../utils/image_utils.dart';

class RegistroService {
  final _api = ApiClient().client;

  Future<Map<String, dynamic>> validarPatrimonio(String codigo, int ativoId) async {
    try {
      final response = await _api.get('/registros/validar-patrimonio', queryParameters: {
        'codigo': codigo,
        'ativoId': ativoId,
      });
      if (response.data != null && response.data['success'] == true) {
        return response.data['data'];
      }
    } catch (e) {
      debugPrint('Erro ao validar patrimônio via API: $e. Validação local...');
    }

    final valido = RegExp(r'^V\d{6}$', caseSensitive: false).hasMatch(codigo);
    return {
      'valido': valido,
      'motivo': valido ? null : 'Patrimônio deve seguir o padrão V + 6 dígitos (ex: V000026)',
      'descricao': valido ? 'Patrimônio Válido' : null,
    };
  }

  Future<bool> salvarRegistro({
    required int visitaId,
    required int ativoId,
    required int unidadeNumero,
    required String status,
    String? patrimonioFisico,
    File? foto,
    double? lat,
    double? lng,
    String? observacao,
  }) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    File? compressedFoto;
    if (foto != null) {
      compressedFoto = await ImageUtils.compressImage(foto);
    }

    if (isOnline) {
      try {
        final Map<String, dynamic> mapData = {
          'visitaId': visitaId,
          'ativoId': ativoId,
          'unidadeNumero': unidadeNumero,
          'status': status,
          'patrimonioFisico': patrimonioFisico ?? '',
          'lat': lat,
          'lng': lng,
          'observacao': observacao ?? '',
        };

        if (compressedFoto != null) {
          mapData['foto'] = await MultipartFile.fromFile(compressedFoto.path);
        }

        final formData = FormData.fromMap(mapData);
        final response = await _api.post('/registros', data: formData);

        if (response.data != null && response.data['success'] == true) {
          // Salvar cópia local marcada como sincronizada
          final db = await LocalDb.database;
          await RegistrosDao(db).salvarRegistro(
            RegistroModel(
              id: response.data['data']['registroId'],
              visitaId: visitaId,
              ativoId: ativoId,
              unidadeNumero: unidadeNumero,
              status: status,
              patrimonioFisico: patrimonioFisico,
              fotoPath: compressedFoto?.path,
              lat: lat,
              lng: lng,
              observacao: observacao,
              sincronizado: true,
              criadoEm: DateTime.now().toIso8601String(),
            ),
          );
          return true;
        }
      } catch (e) {
        debugPrint('Erro ao enviar registro para API online: $e. Salvando localmente para sincronização futura...');
      }
    }

    // Gravação Offline em SQLite (Garante 100% de persistência se sem internet ou queda de rede)
    final db = await LocalDb.database;
    await RegistrosDao(db).salvarRegistro(
      RegistroModel(
        visitaId: visitaId,
        ativoId: ativoId,
        unidadeNumero: unidadeNumero,
        status: status,
        patrimonioFisico: patrimonioFisico,
        fotoPath: compressedFoto?.path,
        lat: lat,
        lng: lng,
        observacao: observacao,
        sincronizado: false,
        criadoEm: DateTime.now().toIso8601String(),
      ),
    );

    return false;
  }
}
