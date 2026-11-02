import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/data/dummy_recipes.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/widgets/favorite_badge_button.dart';
import 'package:resepku/widgets/recipe_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // PERTANYAAN ANALISIS 3: provider sekarang membungkus Scaffold HomePage
    return ChangeNotifierProvider(
      create: (context) => FavoriteProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ResepKu'),
          actions: const [FavoriteBadgeButton()],
        ),
        body: ListView(
          children: [
            for (final recipe in dummyRecipes) RecipeTile(recipe: recipe),
          ],
        ),
      ),
    );
  }
}
