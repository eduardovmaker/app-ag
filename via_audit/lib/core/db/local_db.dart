import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDb {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'via_audit_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE orientadores (
            id INTEGER PRIMARY KEY,
            nome TEXT NOT NULL,
            pin_hash TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE escolas (
            id INTEGER PRIMARY KEY,
            nome TEXT NOT NULL,
            cidade TEXT,
            estado TEXT,
            lat REAL,
            lng REAL,
            status TEXT,
            data_visita_agendada TEXT,
            total_ativos INTEGER DEFAULT 0,
            ativos_conferidos INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE ativos (
            id INTEGER PRIMARY KEY,
            escola_id INTEGER NOT NULL,
            descricao TEXT NOT NULL,
            quantidade INTEGER NOT NULL DEFAULT 1,
            nf TEXT,
            origem TEXT DEFAULT 'historico',
            status_checklist TEXT DEFAULT 'pendente',
            unidades_registradas INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE visitas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orientador_id INTEGER NOT NULL,
            escola_id INTEGER NOT NULL,
            status TEXT DEFAULT 'em_andamento',
            iniciada_em TEXT NOT NULL,
            concluida_em TEXT,
            sincronizado INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE registros (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            local_id TEXT,
            visita_id INTEGER NOT NULL,
            ativo_id INTEGER NOT NULL,
            unidade_numero INTEGER NOT NULL DEFAULT 1,
            status TEXT NOT NULL,
            patrimonio_fisico TEXT,
            foto_path TEXT,
            lat REAL,
            lng REAL,
            observacao TEXT,
            sincronizado INTEGER DEFAULT 0,
            criado_em TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT NOT NULL,
            payload_json TEXT NOT NULL,
            foto_path TEXT,
            tentativas INTEGER DEFAULT 0,
            criado_em TEXT NOT NULL,
            sincronizado INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }
}
