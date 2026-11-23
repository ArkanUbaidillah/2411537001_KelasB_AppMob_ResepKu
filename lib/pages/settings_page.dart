import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/providers/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Latihan 2: konfirmasi, hapus semua favorit, lalu SnackBar
  Future<void> _confirmDeleteAll(BuildContext context, int count) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus semua favorit?'),
        content: Text('$count resep favorit beserta catatannya akan dihapus '
            'dari HP. Tindakan ini tidak dapat dibatalkan.'),
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
    if (confirmed != true || !context.mounted) return;

    await context.read<FavoriteProvider>().clear();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$count resep favorit dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final favoriteCount = context.watch<FavoriteProvider>().count; // Latihan 2

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Mode gelap'),
            value: settings.isDark,
            onChanged: settings.setDark,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.grid_view),
            title: const Text('Tampilan grid'),
            subtitle: const Text('Daftar resep ditampilkan dalam dua kolom'),
            value: settings.isGrid,
            onChanged: settings.setGrid,
          ),
          const Divider(),
          // Latihan 2: hapus semua favorit beserta jumlahnya
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('Hapus semua favorit'),
            subtitle: Text('$favoriteCount resep favorit tersimpan'),
            enabled: favoriteCount > 0,
            onTap: () => _confirmDeleteAll(context, favoriteCount),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Pengaturan tersimpan di HP'),
            subtitle: Text('Pilihan tetap ada walaupun aplikasi ditutup.'),
          ),
        ],
      ),
    );
  }
}
