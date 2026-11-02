import 'package:flutter/material.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/pages/detail_page.dart';

// VERSI EKSPERIMEN: favorit disimpan sebagai state lokal di setiap tile
class RecipeTile extends StatefulWidget {
  const RecipeTile({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<RecipeTile> createState() => _RecipeTileState();
}

class _RecipeTileState extends State<RecipeTile> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return ListTile(
      leading: CircleAvatar(child: Text(recipe.name[0])),
      title: Text(recipe.name),
      subtitle: Text(
        '${recipe.cuisine} • ${recipe.totalTimeMinutes} menit • ★ ${recipe.rating}',
      ),
      trailing: IconButton(
        icon: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.red : null,
        ),
        onPressed: () => setState(() => _isFavorite = !_isFavorite),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPage(recipe: recipe)),
      ),
    );
  }
}
