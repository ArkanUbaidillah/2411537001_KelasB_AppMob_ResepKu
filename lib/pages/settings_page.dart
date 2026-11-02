import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode gelap'),
            subtitle: const Text('Ubah tampilan seluruh aplikasi'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: isDark,
            onChanged: (value) => context.read<ThemeProvider>().toggleTheme(value),
          ),
        ],
      ),
    );
  }
}
