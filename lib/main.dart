import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scan_quest_app/provider/flutter_p2p_connection_provider.dart';
import 'package:scan_quest_app/provider/treasure_items_provider.dart';
import 'package:scan_quest_app/provider/user_provider.dart';
import 'package:scan_quest_app/screens/main_screen.dart';
import 'package:scan_quest_app/utilities/constants.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TreasureItemsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => FlutterP2PConnectionProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
      ],
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
        MainScreen.id: (context) => const MainScreen(),
      },
    );
  }
}
