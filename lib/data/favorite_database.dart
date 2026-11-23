import 'package:path/path.dart' as p;
import 'package:resepku/models/favorite.dart';
import 'package:sqflite/sqflite.dart';

/// Kontrak penyimpanan favorit (Create, Read, Delete; Update menyusul di Bagian C).
/// FavoriteProvider hanya mengenal kontrak ini, bukan SQLite secara langsung.
abstract interface class FavoriteStore {
  Future<List<Favorite>> getAll();
  Future<void> insert(Favorite favorite);
  Future<void> delete(int id);
}

/// Implementasi FavoriteStore dengan SQLite (package sqflite).
class FavoriteDatabase implements FavoriteStore {
  /// factory dan path dapat diganti dari luar, misalnya saat pengujian.
  FavoriteDatabase({DatabaseFactory? factory, String? path})
      : _factory = factory ?? databaseFactorySqflitePlugin,
        _path = path;

  static const _table = 'favorites';

  /// Naikkan angka ini setiap kali struktur tabel berubah.
  static const _version = 1;

  final DatabaseFactory _factory;
  final String? _path; // null = file resepku.db di folder database aplikasi
  Database? _db;

  // Dibuka sekali saat pertama dibutuhkan, lalu dipakai ulang
  Future<Database> get _database async => _db ??= await _open();

  Future<Database> _open() async {
    final path =
        _path ?? p.join(await _factory.getDatabasesPath(), 'resepku.db');
    return _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _version,
        onCreate: _onCreate,
      ),
    );
  }

  // Dipanggil sekali ketika file database belum ada (instalasi baru)
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_table (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        data TEXT NOT NULL,
        saved_at INTEGER NOT NULL
      )
    ''');
  }

  // READ: semua favorit, yang terbaru disimpan di atas
  @override
  Future<List<Favorite>> getAll() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'saved_at DESC');
    return rows.map(Favorite.fromMap).toList();
  }

  // CREATE: id yang sudah ada diganti, bukan error
  @override
  Future<void> insert(Favorite favorite) async {
    final db = await _database;
    await db.insert(
      _table,
      favorite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // DELETE: satu baris berdasarkan id
  @override
  Future<void> delete(int id) async {
    final db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
