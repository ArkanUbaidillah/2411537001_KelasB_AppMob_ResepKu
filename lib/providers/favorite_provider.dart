import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:resepku/data/favorite_database.dart';
import 'package:resepku/models/favorite.dart';
import 'package:resepku/models/recipe.dart';

/// Daftar resep favorit. Isinya disimpan di memori agar widget dapat
/// membacanya tanpa await, dan setiap perubahan ditulis ke FavoriteStore.
class FavoriteProvider extends ChangeNotifier {
  FavoriteProvider(this._store);

  final FavoriteStore _store;
  List<Favorite> _items = [];

  // Dari luar hanya boleh dibaca, tidak boleh diubah langsung
  UnmodifiableListView<Favorite> get items => UnmodifiableListView(_items);
  int get count => _items.length;

  bool isFavorite(Recipe recipe) =>
      _items.any((f) => f.recipe.id == recipe.id);

  /// Mengisi memori dari penyimpanan saat aplikasi dibuka.
  Future<void> load() async {
    _items = await _store.getAll();
    notifyListeners();
  }

  Future<void> toggle(Recipe recipe) async {
    if (isFavorite(recipe)) {
      _items.removeWhere((f) => f.recipe.id == recipe.id);
      notifyListeners(); // tampilan berubah lebih dulu
      await _store.delete(recipe.id); // lalu ditulis ke database
    } else {
      final favorite = Favorite(recipe: recipe, savedAt: DateTime.now());
      _items.insert(0, favorite); // terbaru di atas, sama dengan urutan query
      notifyListeners();
      await _store.insert(favorite);
    }
  }
}
