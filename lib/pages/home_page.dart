import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/pages/add_recipe_page.dart';
import 'package:resepku/pages/settings_page.dart';
import 'package:resepku/services/recipe_service.dart';
import 'package:resepku/widgets/error_view.dart';
import 'package:resepku/widgets/favorite_badge_button.dart';
import 'package:resepku/widgets/recipe_grid_card.dart';
import 'package:resepku/widgets/recipe_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGrid = false;
  String? _cuisine; // Latihan 1 Modul 7: null berarti semua cuisine
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    // Future dibuat SEKALI di initState, bukan di build()
    _recipesFuture = context.read<RecipeService>().fetchRecipes();
  }

  // Membuat Future baru, lalu setState agar FutureBuilder memakainya
  void _reload() {
    setState(() {
      _recipesFuture = context.read<RecipeService>().fetchRecipes();
    });
  }

  // Dipanggil RefreshIndicator saat daftar ditarik ke bawah
  Future<void> _refresh() async {
    _reload();
    try {
      await _recipesFuture;
    } catch (_) {
      // error sudah ditampilkan oleh FutureBuilder
    }
  }

  Future<void> _openAddPage() async {
    final created = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(builder: (context) => const AddRecipePage()),
    );
    if (created == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${created.name}" diterima server dengan id ${created.id}. '
          'dummyjson hanya menyimulasikan penyimpanan.',
        ),
      ),
    );
  }

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
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          // 1. Loading state (data lama tetap tampil saat refresh)
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Error state
          if (snapshot.hasError) {
            return ErrorView(
              message: 'Gagal memuat resep.\n${snapshot.error}',
              onRetry: _reload,
            );
          }
          // 3. Data state
          final recipes = snapshot.data ?? [];
          if (recipes.isEmpty) {
            return const Center(child: Text('Belum ada resep.'));
          }

          // Latihan 1 Modul 7: daftar cuisine diambil dari data hasil
          // FutureBuilder (variabel recipes), bukan dari dummyRecipes
          final cuisines = recipes.map((r) => r.cuisine).toSet().toList()..sort();
          final filtered = _cuisine == null
              ? recipes
              : recipes.where((r) => r.cuisine == _cuisine).toList();

          return Column(
            children: [
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  children: [
                    _buildChip('Semua', null),
                    for (final cuisine in cuisines) _buildChip(cuisine, cuisine),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: _isGrid ? _buildGrid(filtered) : _buildList(filtered),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah resep',
        onPressed: _openAddPage,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChip(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: _cuisine == value,
        onSelected: (_) => setState(() => _cuisine = value),
      ),
    );
  }

  Widget _buildList(List<Recipe> recipes) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) => RecipeTile(recipe: recipes[index]),
    );
  }

  Widget _buildGrid(List<Recipe> recipes) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 4, // lebar : tinggi
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) => RecipeGridCard(recipe: recipes[index]),
    );
  }
}
