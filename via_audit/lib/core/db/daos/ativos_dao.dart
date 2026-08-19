import 'package:sqflite/sqflite.dart';
import '../../models/ativo_model.dart';

class AtivosDao {
  final Database db;
  AtivosDao(this.db);

  Future<void> salvarAtivos(List<AtivoModel> ativos) async {
    final batch = db.batch();
    for (var a in ativos) {
      batch.insert(
        'ativos',
        a.toSqliteMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> salvarAtivo(AtivoModel ativo) async {
    await db.insert(
      'ativos',
      ativo.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AtivoModel>> listarPorEscola(int escolaId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'ativos',
      where: 'escola_id = ?',
      whereArgs: [escolaId],
    );
    return maps.map((m) => AtivoModel.fromJson(m)).toList();
  }
}
