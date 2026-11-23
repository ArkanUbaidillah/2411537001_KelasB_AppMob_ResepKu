import 'dart:convert';

import 'package:resepku/models/recipe.dart';

/// Satu resep favorit beserta data milik pengguna: catatan dan waktu disimpan.
class Favorite {
  const Favorite({
    required this.recipe,
    required this.savedAt,
    this.note = '',
    this.cookedCount = 0, // Latihan 3
  });

  final Recipe recipe;
  final DateTime savedAt;
  final String note;
  final int cookedCount; // Latihan 3: berapa kali resep sudah dimasak

  Favorite copyWith({String? note, int? cookedCount}) {
    // Objek ini immutable: perubahan menghasilkan objek baru
    return Favorite(
      recipe: recipe,
      savedAt: savedAt,
      note: note ?? this.note,
      cookedCount: cookedCount ?? this.cookedCount,
    );
  }

  /// Objek -> satu baris tabel. Key Map = nama kolom.
  Map<String, Object?> toMap() {
    return {
      'id': recipe.id,
      'name': recipe.name,
      'data': jsonEncode(recipe.toJson()), // seluruh resep
      'note': note,
      'cooked_count': cookedCount, // Latihan 3
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
      cookedCount: map['cooked_count'] as int? ?? 0, // Latihan 3
      savedAt: DateTime.fromMillisecondsSinceEpoch(map['saved_at'] as int),
    );
  }
}
