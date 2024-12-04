import 'package:flutter/material.dart';
import 'package:scan_quest_app/screens/inventory_screen.dart';
import 'package:scan_quest_app/screens/loading_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: InventoryScreen.id,
      routes: {
        LoadingScreen.id: (context) => const LoadingScreen(),
        InventoryScreen.id: (context) => const InventoryScreen(),
      },
    );
  }
}
