import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'screens/home_screen.dart';
import 'widgets/scanline_overlay.dart';

class MorseApp extends StatelessWidget {
  const MorseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morse Code Game',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      builder: (context, child) => ScanlineOverlay(child: child!),
      home: const HomeScreen(),
    );
  }
}
