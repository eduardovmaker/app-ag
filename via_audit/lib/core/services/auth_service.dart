import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/orientador_model.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _api = ApiClient().client;

  /// Mapa de orientadores e credenciais para fallback offline / ambiente local
  static const Map<String, Map<String, dynamic>> mockOrientadoresByPin = {
    '873914': {'id': 9999, 'nome': 'Administrador Geral', 'role': 'admin', 'totalEscolas': 229},
    '935703': {'id': 1, 'nome': 'Adolfo', 'role': 'orientador', 'totalEscolas': 14},
    '324104': {'id': 2, 'nome': 'Adriele Pereira', 'role': 'orientador', 'totalEscolas': 14},
    '508581': {'id': 3, 'nome': 'Aline Gomes', 'role': 'orientador', 'totalEscolas': 13},
    '159233': {'id': 4, 'nome': 'Amarildo Junior', 'role': 'orientador', 'totalEscolas': 11},
    '141204': {'id': 5, 'nome': 'Ana Paula Lima', 'role': 'orientador', 'totalEscolas': 15},
    '981409': {'id': 6, 'nome': 'Carlos Matos', 'role': 'orientador', 'totalEscolas': 16},
    '579245': {'id': 7, 'nome': 'Daniel Santos', 'role': 'orientador', 'totalEscolas': 18},
    '173980': {'id': 8, 'nome': 'Elienai Cordova', 'role': 'orientador', 'totalEscolas': 10},
    '825512': {'id': 9, 'nome': 'Everton Neves', 'role': 'orientador', 'totalEscolas': 7},
    '644863': {'id': 10, 'nome': 'Gabriel Felisbino', 'role': 'orientador', 'totalEscolas': 11},
    '165214': {'id': 11, 'nome': 'Gabrielly Silva', 'role': 'orientador', 'totalEscolas': 11},
    '920039': {'id': 12, 'nome': 'Helen Silva', 'role': 'orientador', 'totalEscolas': 12},
    '747945': {'id': 13, 'nome': 'Jhonatan Luna', 'role': 'orientador', 'totalEscolas': 23},
    '752135': {'id': 14, 'nome': 'Lara Lima', 'role': 'orientador', 'totalEscolas': 15},
    '556553': {'id': 15, 'nome': 'Mariana Munhoz', 'role': 'orientador', 'totalEscolas': 17},
    '198919': {'id': 16, 'nome': 'Mirella Bernardinelli', 'role': 'orientador', 'totalEscolas': 13},
    '415988': {'id': 17, 'nome': 'Sabrina Moraes', 'role': 'orientador', 'totalEscolas': 9},
    '123456': {'id': 5, 'nome': 'Ana Paula Lima', 'role': 'orientador', 'totalEscolas': 15},
    '724123': {'id': 5, 'nome': 'Ana Paula Lima', 'role': 'orientador', 'totalEscolas': 15},
  };

  Future<OrientadorModel?> login(String pin) async {
    if (pin.length != 6 && pin.length != 4) {
      throw Exception('O PIN deve conter 4 ou 6 dígitos.');
    }

    try {
      final response = await _api.post('/auth/login', data: {'pin': pin});
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        final orientador = OrientadorModel.fromJson(data);
        final userRole = data['role'] ?? (orientador.id == 9999 ? 'admin' : 'orientador');

        if (data['token'] != null) {
          await _storage.write(key: 'jwtToken', value: data['token'].toString());
        }
        await _storage.write(key: 'orientadorId', value: orientador.id.toString());
        await _storage.write(key: 'orientadorNome', value: orientador.nome);
        await _storage.write(key: 'userRole', value: userRole);
        return orientador;
      } else {
        throw Exception(response.data['error'] ?? 'PIN inválido ou orientador inativo.');
      }
    } catch (e) {
      debugPrint('Erro no login via API: $e. Tentando fallback local...');
      
      final mockData = mockOrientadoresByPin[pin];
      if (mockData != null || kDebugMode) {
        final data = mockData ?? {'id': 5, 'nome': 'Ana Paula Lima', 'role': 'orientador', 'totalEscolas': 15};
        final userRole = data['role'] ?? (data['id'] == 9999 ? 'admin' : 'orientador');
        final orientador = OrientadorModel(
          id: data['id'] as int,
          nome: data['nome'] as String,
          totalEscolas: data['totalEscolas'] as int,
          escolasVisitadas: 0,
        );
        await _storage.write(key: 'orientadorId', value: orientador.id.toString());
        await _storage.write(key: 'orientadorNome', value: orientador.nome);
        await _storage.write(key: 'userRole', value: userRole.toString());
        return orientador;
      }
      throw Exception('PIN não reconhecido ou sem conexão com o servidor.');
    }
  }

  Future<String?> getSavedOrientadorId() async {
    return await _storage.read(key: 'orientadorId');
  }

  Future<String?> getSavedOrientadorNome() async {
    return await _storage.read(key: 'orientadorNome');
  }

  Future<String?> getSavedUserRole() async {
    return await _storage.read(key: 'userRole');
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
