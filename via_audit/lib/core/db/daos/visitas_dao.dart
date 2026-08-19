import 'package:sqflite/sqflite.dart';
import '../../models/visita_model.dart';

class VisitasDao {
  final Database db;
  VisitasDao(this.db);

  Future<int> salvarVisita(VisitaModel visita) async {
    return await db.insert(
      'visitas',
      visita.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<VisitaModel?> buscarEmAndamento(int orientadorId, int escolaId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'visitas',
      where: 'orientador_id = ? AND escola_id = ? AND status = ?',
      whereArgs: [orientadorId, escolaId, 'em_andamento'],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return VisitaModel.fromJson(maps.first);
    }
    return null;
  }
}
