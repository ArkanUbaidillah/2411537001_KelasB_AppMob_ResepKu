import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:resepku/main.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/providers/settings_provider.dart';
import 'package:resepku/services/recipe_service.dart';
import 'package:resepku/widgets/recipe_grid_card.dart';
import 'package:resepku/widgets/recipe_tile.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fakes.dart';
import 'fixtures.dart';

/// Server palsu yang selalu menjawab daftar resep dari fixtures.dart.
http.Client okClient() =>
    MockClient((request) async => http.Response(recipesJson, 200));

/// Server palsu yang selalu gagal.
http.Client errorClient() =>
    MockClient((request) async => http.Response('Server error', 500));

/// Layar seukuran HP: 360 x 740 dp.
void usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2220);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

// Penyimpanan favorit di memori (fakes.dart), sehingga test tidak membutuhkan
// SQLite. SettingsProvider membaca SharedPreferences tiruan dari setUp.
Widget buildApp(
  http.Client client, {
  MemoryFavoriteStore? store,
  SettingsProvider? settings,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => settings ?? SettingsProvider()),
      ChangeNotifierProvider(
        create: (context) =>
            FavoriteProvider(store ?? MemoryFavoriteStore())..load(),
      ),
      Provider(create: (context) => RecipeService(client: client)),
    ],
    child: const ResepKuApp(),
  );
}

void main() {
  setUp(() {
    // SharedPreferences di memori, kosong pada awal setiap test
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('Home menampilkan resep dari server', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(buildApp(okClient()));
    await tester.pumpAndSettle();

    expect(find.text('Classic Margherita Pizza'), findsOneWidget);
    expect(find.byType(RecipeTile), findsWidgets);
  });

  testWidgets('ErrorView tampil saat server gagal', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(buildApp(errorClient()));
    await tester.pumpAndSettle();

    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('Halaman detail menampilkan porsi dan langkah memasak',
      (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(buildApp(okClient()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Classic Margherita Pizza'));
    await tester.pumpAndSettle();
    expect(find.text('Porsi'), findsOneWidget);

    // Bagian Langkah ada di bawah: scroll sampai terlihat
    await tester.dragUntilVisible(
      find.text('Langkah'),
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    expect(find.text('Langkah'), findsOneWidget);
  });

  testWidgets('Pilihan grid dibaca dari SharedPreferences saat aplikasi dibuka',
      (tester) async {
    usePhoneSize(tester);
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({SettingsProvider.keyGrid: true});
    final settings = SettingsProvider();
    await settings.load(); // seperti di main, sebelum runApp

    await tester.pumpWidget(buildApp(okClient(), settings: settings));
    await tester.pumpAndSettle();
    expect(find.byType(RecipeGridCard), findsWidgets);
    expect(find.byType(RecipeTile), findsNothing);
  });

  testWidgets('Favorit dan catatan yang tersimpan tampil saat aplikasi dibuka',
      (tester) async {
    usePhoneSize(tester);
    final store = MemoryFavoriteStore([sampleFavorite(note: 'Tambah keju')]);

    await tester.pumpWidget(buildApp(okClient(), store: store));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget); // badge dari data tersimpan

    await tester.tap(find.byTooltip('Favorit saya'));
    await tester.pumpAndSettle();
    expect(find.text('Classic Margherita Pizza'), findsOneWidget);
    // textContaining: subtitle boleh berisi teks lain, misalnya jumlah dimasak
    expect(find.textContaining('Tambah keju'), findsOneWidget);
  });
}
