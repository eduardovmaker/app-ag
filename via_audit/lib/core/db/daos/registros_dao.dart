import 'package:sqflite/sqflite.dart';
import '../../models/registro_model.dart';

class RegistrosDao {
  final Database db;
  RegistrosDao(this.db);

  Future<int> salvarRegistro(RegistroModel registro) async {
    return await db.insert(
      'registros',
      registro.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<RegistroModel>> listarPorVisita(int visitaId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'registros',
      where: 'visita_id = ?',
      whereArgs: [visitaId],
    );
    return maps.map((m) => RegistroModel.fromJson(m)).toList();
  }

  Future<List<RegistroModel>> listarNaoSincronizados() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'registros',
      where: 'sincronizado = 0',
    );
    return maps.map((m) => RegistroModel.fromJson(m)).toList();
  }

  Future<void> marcarComoSincronizado(int id) async {
    await db.update(
      'registros',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<RegistroModel>> listarTodos() async {
    final List<Map<String, dynamic>> maps = await db.query('registros');
    return maps.map((m) => RegistroModel.fromJson(m)).toList();
  }
}
