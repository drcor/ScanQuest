import 'package:flutter/material.dart';
import 'package:scan_quest_app/screens/loading_screen.dart';
import 'package:scan_quest_app/screens/main_screen.dart';
import 'package:scan_quest_app/utilities/constants.dart';

void main() {
  runApp(const MainApp());
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
