import 'package:flutter/material.dart';
import 'package:resepku/data/dummy_recipes.dart';
import 'package:resepku/pages/settings_page.dart';
import 'package:resepku/widgets/favorite_badge_button.dart';
import 'package:resepku/widgets/recipe_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('ResepKu'),
          ],
        ),
        actions: [
          const FavoriteBadgeButton(),
          // tombol Pengaturan dari Latihan 1 Modul 6 tetap dipertahankan
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: dummyRecipes.length,
        itemBuilder: (context, index) {
          return RecipeTile(recipe: dummyRecipes[index]);
        },
      ),
    );
  }
}
