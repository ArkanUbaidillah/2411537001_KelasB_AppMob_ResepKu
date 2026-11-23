import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Latihan 1: pilihan urutan halaman Favorit.
enum FavoriteSort { newest, name }

/// Pengaturan aplikasi yang disimpan di HP dengan SharedPreferencesAsync.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({SharedPreferencesAsync? prefs})
      : _prefs = prefs ?? SharedPreferencesAsync();

  static const keyGrid = 'is_grid';
  static const keyDark = 'is_dark';
  static const keySort = 'favorite_sort'; // Latihan 1

  final SharedPreferencesAsync _prefs;

  // Nilai saat ini disimpan di field agar build() dapat membacanya tanpa await
  bool _isGrid = false;
  bool _isDark = false;
  FavoriteSort _sort = FavoriteSort.newest; // Latihan 1

  bool get isGrid => _isGrid;
  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;
  FavoriteSort get favoriteSort => _sort;

  /// Dipanggil sekali di main, sebelum runApp.
  Future<void> load() async {
    // null berarti key belum pernah disimpan (pembukaan pertama)
    _isGrid = await _prefs.getBool(keyGrid) ?? false;
    _isDark = await _prefs.getBool(keyDark) ?? false;
    // Enum disimpan sebagai String (nama nilainya), lalu diubah kembali.
    // Nilai yang tidak dikenal atau belum ada kembali ke newest.
    final sortName = await _prefs.getString(keySort);
    _sort = FavoriteSort.values.asNameMap()[sortName] ?? FavoriteSort.newest;
    notifyListeners();
  }

  Future<void> setGrid(bool value) async {
    _isGrid = value;
    notifyListeners(); // tampilan berubah lebih dulu
    await _prefs.setBool(keyGrid, value); // lalu disimpan
  }

  Future<void> setDark(bool value) async {
    _isDark = value;
    notifyListeners();
    await _prefs.setBool(keyDark, value);
  }

  // Latihan 1: urutan favorit
  Future<void> setFavoriteSort(FavoriteSort value) async {
    _sort = value;
    notifyListeners();
    await _prefs.setString(keySort, value.name);
  }
}
