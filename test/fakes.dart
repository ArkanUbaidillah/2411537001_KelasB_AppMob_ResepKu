import 'dart:convert';

import 'package:resepku/data/favorite_database.dart';
import 'package:resepku/models/favorite.dart';
import 'package:resepku/models/recipe.dart';

import 'fixtures.dart';

/// FavoriteStore di memori: pengganti SQLite pada widget test.
class MemoryFavoriteStore implements FavoriteStore {
  MemoryFavoriteStore([List<Favorite> initial = const []])
      : _rows = [...initial];

  final List<Favorite> _rows;

  @override
  Future<List<Favorite>> getAll() async {
    // Salinan baru, terbaru di atas (sama seperti query di FavoriteDatabase)
    return [..._rows]..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  @override
  Future<void> insert(Favorite favorite) async {
    _rows.removeWhere((f) => f.recipe.id == favorite.recipe.id);
    _rows.add(favorite);
  }

  @override
  Future<void> updateNote(int id, String note) async {
    final index = _rows.indexWhere((f) => f.recipe.id == id);
    if (index >= 0) _rows[index] = _rows[index].copyWith(note: note);
  }

  @override
  Future<void> delete(int id) async {
    _rows.removeWhere((f) => f.recipe.id == id);
  }

  // Latihan 2
  @override
  Future<void> deleteAll() async {
    _rows.clear();
  }
}

/// Favorit contoh: resep pertama di fixtures.dart (Classic Margherita Pizza).
Favorite sampleFavorite({String note = ''}) {
  final json = (jsonDecode(recipesJson)['recipes'] as List).first
      as Map<String, dynamic>;
  return Favorite(
    recipe: Recipe.fromJson(json),
    savedAt: DateTime(2026, 10, 1),
    note: note,
  );
}
