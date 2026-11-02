import 'package:flutter/material.dart';
import 'package:resepku/pages/home_page.dart';
import 'package:resepku/widgets/identity_footer.dart';

// PERTANYAAN ANALISIS 3 (sengaja salah):
// ChangeNotifierProvider dipindah dari main() ke dalam HomePage.
void main() {
  runApp(const ResepKuApp());
}

class ResepKuApp extends StatelessWidget {
  const ResepKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResepKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange),
      builder: (context, child) => IdentityFooter(child: child!), // tetap dipertahankan
      home: const HomePage(),
    );
  }
}
