import 'package:flutter/material.dart';

// GANTI dengan NIM dan nama lengkap Kalian sendiri
const String kNim = '2411537001';
const String kNama = 'Arkan Ubaidillah Warman';

/// Menampilkan NIM dan nama di bawah setiap halaman.
/// Dipasang sekali di MaterialApp.builder, jadi berlaku untuk semua route.
class IdentityFooter extends StatelessWidget {
  const IdentityFooter({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          // ruang aman bawah sudah diurus footer, jadi tidak dihitung dua kali
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: child,
          ),
        ),
        Material(
          color: Colors.black87,
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  '$kNim • $kNama',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
