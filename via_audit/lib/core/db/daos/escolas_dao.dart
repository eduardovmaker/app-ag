import 'package:sqflite/sqflite.dart';
import '../../models/escola_model.dart';

class EscolasDao {
  final Database db;
  EscolasDao(this.db);

  Future<void> salvarEscolas(List<EscolaModel> escolas) async {
    final batch = db.batch();
    for (var e in escolas) {
      batch.insert(
        'escolas',
        e.toSqliteMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<EscolaModel>> listarPorOrientador(int orientadorId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'escolas',
      orderBy: "CASE status WHEN 'pendente' THEN 1 WHEN 'em_andamento' THEN 2 WHEN 'concluida' THEN 3 ELSE 4 END, data_visita_agendada ASC",
    );
    return maps.map((m) => EscolaModel.fromJson(m)).toList();
  }

  Future<void> atualizarStatusEscola(int escolaId, String status) async {
    await db.update(
      'escolas',
      {'status': status},
      where: 'id = ?',
      whereArgs: [escolaId],
    );
  }
}
