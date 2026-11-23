// Unit test FavoriteDatabase dengan SQLite versi komputer (sqflite_common_ffi).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:resepku/data/favorite_database.dart';
import 'package:resepku/models/favorite.dart';
import 'package:resepku/models/recipe.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const rendang = Recipe(
  id: 1,
  name: 'Rendang',
  cuisine: 'Indonesian',
  difficulty: 'Hard',
  prepTimeMinutes: 30,
  cookTimeMinutes: 180,
  servings: 6,
  caloriesPerServing: 450,
  rating: 4.9,
  image: '',
  ingredients: ['Daging sapi', 'Santan', 'Cabai'],
  instructions: ['Tumis bumbu.', 'Masak dengan santan hingga kering.'],
);

const soto = Recipe(
  id: 2,
  name: 'Soto Padang',
  cuisine: 'Indonesian',
  difficulty: 'Medium',
  prepTimeMinutes: 20,
  cookTimeMinutes: 60,
  servings: 4,
  caloriesPerServing: 300,
  rating: 4.7,
  image: '',
  ingredients: ['Daging sapi', 'Bihun'],
);

final favRendang = Favorite(recipe: rendang, savedAt: DateTime(2026, 10, 1));
final favSoto = Favorite(recipe: soto, savedAt: DateTime(2026, 10, 2));

void main() {
  sqfliteFfiInit(); // SQLite versi komputer

  late FavoriteDatabase db;

  // Database di memori: setiap test mulai dari kosong
  setUp(() => db = FavoriteDatabase(
      factory: databaseFactoryFfi, path: inMemoryDatabasePath));
  tearDown(() => db.close());

  test('insert lalu getAll, yang terbaru di atas', () async {
    await db.insert(favRendang);
    await db.insert(favSoto);

    final all = await db.getAll();
    expect(all.map((f) => f.recipe.name), ['Soto Padang', 'Rendang']);
  });

  test('resep tersimpan utuh, termasuk bahan dan langkah', () async {
    await db.insert(favRendang);

    final saved = (await db.getAll()).single;
    expect(saved.recipe.ingredients, rendang.ingredients);
    expect(saved.recipe.instructions, hasLength(2));
    expect(saved.savedAt, DateTime(2026, 10, 1));
  });

  test('insert id yang sama mengganti baris lama', () async {
    await db.insert(favRendang);
    await db.insert(favRendang.copyWith(note: 'versi baru'));

    final all = await db.getAll();
    expect(all, hasLength(1));
    expect(all.single.note, 'versi baru');
  });

  test('updateNote dan delete', () async {
    await db.insert(favRendang);
    await db.updateNote(1, 'Kurangi santan');
    expect((await db.getAll()).first.note, 'Kurangi santan');

    await db.delete(1);
    expect(await db.getAll(), isEmpty);
  });

  test('migrasi versi 1 ke 2 tidak menghapus data', () async {
    final dir = await Directory.systemTemp.createTemp('resepku_test');
    final path = p.join(dir.path, 'lama.db');

    // 1. Tabel versi 1 dibuat manual, tanpa kolom note, lalu diisi satu baris
    final old = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) => db.execute(
          'CREATE TABLE favorites (id INTEGER PRIMARY KEY, name TEXT NOT NULL, '
          'data TEXT NOT NULL, saved_at INTEGER NOT NULL)',
        ),
      ),
    );
    // Hanya kolom versi 1: toMap terbaru bisa berisi kolom baru (note, cooked_count, ...)
    final row = favRendang.toMap();
    await old.insert('favorites', {
      for (final column in ['id', 'name', 'data', 'saved_at']) column: row[column],
    });
    await old.close();

    // 2. File yang sama dibuka oleh FavoriteDatabase versi 2 -> onUpgrade
    final upgraded = FavoriteDatabase(factory: databaseFactoryFfi, path: path);
    final all = await upgraded.getAll();
    expect(all.single.recipe.name, 'Rendang'); // data lama tetap ada
    expect(all.single.note, ''); // kolom baru berisi DEFAULT

    await upgraded.updateNote(1, 'Pedas');
    expect((await upgraded.getAll()).single.note, 'Pedas');

    await upgraded.close();
    await dir.delete(recursive: true);
  });
}
