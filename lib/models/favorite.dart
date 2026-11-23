import 'dart:convert';

import 'package:resepku/models/recipe.dart';

/// Satu resep favorit beserta data milik pengguna: catatan dan waktu disimpan.
class Favorite {
  const Favorite({
    required this.recipe,
    required this.savedAt,
    this.note = '',
  });

  final Recipe recipe;
  final DateTime savedAt;
  final String note;

  Favorite copyWith({String? note}) {
    // Objek ini immutable: perubahan menghasilkan objek baru
    return Favorite(recipe: recipe, savedAt: savedAt, note: note ?? this.note);
  }

  /// Objek -> satu baris tabel. Key Map = nama kolom.
  Map<String, Object?> toMap() {
    return {
      'id': recipe.id,
      'name': recipe.name,
      'data': jsonEncode(recipe.toJson()), // seluruh resep
      'note': note,
      // SQLite tidak punya tipe tanggal: simpan milidetik
      'saved_at': savedAt.millisecondsSinceEpoch,
    };
  }

  /// Satu baris tabel -> objek. Kebalikan toMap.
  factory Favorite.fromMap(Map<String, Object?> map) {
    final json = jsonDecode(map['data'] as String);
    return Favorite(
      recipe: Recipe.fromJson(json as Map<String, dynamic>),
      note: map['note'] as String? ?? '',
      savedAt: DateTime.fromMillisecondsSinceEpoch(map['saved_at'] as int),
    );
  }
}
