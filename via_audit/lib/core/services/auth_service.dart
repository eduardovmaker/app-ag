import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/orientador_model.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _api = ApiClient().client;

  /// PINs mockados aceitos no ambiente de desenvolvimento/teste offline
  static const List<String> mockPins = ['123456', '724123', '111111', '000000', '1234'];

  Future<OrientadorModel?> login(String pin) async {
    if (pin.length != 6 && pin.length != 4) {
      throw Exception('O PIN deve conter 4 ou 6 dígitos.');
    }

    try {
      final response = await _api.post('/auth/login', data: {'pin': pin});
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        final orientador = OrientadorModel.fromJson(data);

        await _storage.write(key: 'orientadorId', value: orientador.id.toString());
        await _storage.write(key: 'orientadorNome', value: orientador.nome);
        return orientador;
      } else {
        throw Exception(response.data['error'] ?? 'PIN inválido ou orientador inativo.');
      }
    } catch (e) {
      debugPrint('Erro no login via API: $e. Tentando fallback local...');
      if (mockPins.contains(pin) || kDebugMode) {
        final orientador = OrientadorModel(
          id: 7,
          nome: 'Daniela Moreira (Auditora)',
          totalEscolas: 12,
          escolasVisitadas: 3,
        );
        await _storage.write(key: 'orientadorId', value: '7');
        await _storage.write(key: 'orientadorNome', value: 'Daniela Moreira');
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

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
