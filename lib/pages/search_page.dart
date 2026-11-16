import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/services/recipe_service.dart';
import 'package:resepku/widgets/error_view.dart';
import 'package:resepku/widgets/recipe_tile.dart';

/// Latihan 1: halaman pencarian resep.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _queryController = TextEditingController();
  // null sebelum user mencari
  Future<List<Recipe>>? _searchFuture;
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _search(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    // Future baru dibuat di dalam setState, bukan di build()
    setState(() {
      _query = query;
      _searchFuture = context.read<RecipeService>().searchRecipes(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _queryController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cari resep, misalnya pasta',
            border: InputBorder.none,
          ),
          onSubmitted: _search, // dipanggil saat Enter ditekan
        ),
        actions: [
          IconButton(
            tooltip: 'Cari',
            icon: const Icon(Icons.search),
            onPressed: () => _search(_queryController.text),
          ),
        ],
      ),
      body: _searchFuture == null
          ? const Center(child: Text('Ketik kata kunci, lalu tekan Enter.'))
          : FutureBuilder<List<Recipe>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                // 1. Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 2. Error state
                if (snapshot.hasError) {
                  return ErrorView(
                    message: 'Gagal mencari resep.\n${snapshot.error}',
                    onRetry: () => _search(_query),
                  );
                }
                // 3. Hasil kosong
                final recipes = snapshot.data ?? [];
                if (recipes.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada resep untuk "$_query".',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                // 4. Hasil pencarian
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) =>
                      RecipeTile(recipe: recipes[index]),
                );
              },
            ),
    );
  }
}
