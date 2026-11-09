import 'package:flutter/material.dart';
import 'package:resepku/data/dummy_recipes.dart';
import 'package:resepku/pages/settings_page.dart';
import 'package:resepku/widgets/favorite_badge_button.dart';
import 'package:resepku/widgets/recipe_grid_card.dart';
import 'package:resepku/widgets/recipe_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGrid = false; // ephemeral state: hanya HomePage yang membutuhkan

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
          IconButton(
            tooltip: _isGrid ? 'Tampilan list' : 'Tampilan grid',
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
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
      body: _isGrid ? _buildGrid() : _buildList(),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: dummyRecipes.length,
      itemBuilder: (context, index) {
        return RecipeTile(recipe: dummyRecipes[index]);
      },
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 4, // lebar : tinggi
      ),
      itemCount: dummyRecipes.length,
      itemBuilder: (context, index) {
        return RecipeGridCard(recipe: dummyRecipes[index]);
      },
    );
  }
}
