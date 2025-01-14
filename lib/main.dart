import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scan_quest_app/provider/treasure_items_provider.dart';
import 'package:scan_quest_app/screens/loading_screen.dart';
import 'package:scan_quest_app/screens/main_screen.dart';
import 'package:scan_quest_app/utilities/constants.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TreasureItemsProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: defaultThemeData,
      initialRoute: MainScreen.id,
      routes: {
        LoadingScreen.id: (context) => const LoadingScreen(),
        MainScreen.id: (context) => const MainScreen(),
      },
    );
  }
}
