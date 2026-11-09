import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/widgets/recipe_image.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit Saya'),
        actions: [
          // Consumer: tombol ikut rebuild saat jumlah favorit berubah
          Consumer<FavoriteProvider>(
            builder: (context, favorite, child) => TextButton.icon(
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Hapus semua'),
              // null = tombol nonaktif ketika daftar favorit kosong
              onPressed: favorite.count == 0 ? null : () => _confirmClear(context),
            ),
          ),
        ],
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favorite, child) {
          if (favorite.count == 0) {
            return const Center(
              child: Text(
                'Belum ada resep favorit.\nTekan ikon hati di daftar resep.',
                textAlign: TextAlign.center,
              ),
            );
          }
          final items = favorite.items;
          // Latihan 2: separated menyisipkan Divider di antara item
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final recipe = items[index];
              return Dismissible(
                // key unik dan stabil: id resep, bukan index
                key: ValueKey(recipe.id),
                direction: DismissDirection.endToStart, // geser ke kiri
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  favorite.toggle(recipe); // hapus dari favorit
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('${recipe.name} dihapus dari favorit'),
                      ),
                    );
                },
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: RecipeImage(url: recipe.image, cacheWidth: 168),
                    ),
                  ),
                  title: Text(recipe.name),
                  subtitle: Text(recipe.cuisine),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => favorite.toggle(recipe),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus semua favorit?'),
        content: const Text('Semua resep akan dihapus dari daftar favorit.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    // clear() hanya dipanggil kalau pengguna menekan "Hapus"
    if (confirmed == true && context.mounted) {
      context.read<FavoriteProvider>().clear();
    }
  }
}
