import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/data/favorite_database.dart';
import 'package:resepku/pages/home_page.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/providers/settings_provider.dart';
import 'package:resepku/services/recipe_service.dart';
import 'package:resepku/widgets/identity_footer.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  // Wajib sebelum memakai plugin di dalam main
  WidgetsFlutterBinding.ensureInitialized();

  // Tambahan untuk Windows/Linux: plugin sqflite hanya ada di Android, iOS,
  // dan macOS. Di desktop dipakai SQLite versi komputer (sqflite_common_ffi).
  // Di Android, desktopFactory bernilai null sehingga FavoriteDatabase
  // tetap memakai databaseFactorySqflitePlugin seperti di modul.
  DatabaseFactory? desktopFactory;
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    desktopFactory = databaseFactoryFfi;
  }

  final settings = SettingsProvider();
  final favorites = FavoriteProvider(FavoriteDatabase(factory: desktopFactory));
  await Future.wait([settings.load(), favorites.load()]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: favorites),
        // Provider biasa: RecipeService tidak berubah, jadi tidak perlu notifyListeners
        Provider(
          create: (context) => RecipeService(),
          dispose: (context, service) => service.close(),
        ),
      ],
      child: const ResepKuApp(),
    ),
  );
}

class ResepKuApp extends StatelessWidget {
  const ResepKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<SettingsProvider>().themeMode;

    return MaterialApp(
      title: 'ResepKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        fontFamily: 'Poppins', // didaftarkan di pubspec.yaml
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
      ),
      themeMode: themeMode,
      builder: (context, child) => IdentityFooter(child: child!), // footer NIM & nama (Modul 6)
      home: const HomePage(),
    );
  }
}
