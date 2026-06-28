import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class MorseApp extends StatelessWidget {
  const MorseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32),
      brightness: Brightness.dark,
    );
    return MaterialApp(
      title: 'Morse Code Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
      ),
      home: const HomeScreen(),
    );
  }
}
