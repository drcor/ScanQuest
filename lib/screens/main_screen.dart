import 'package:flutter/material.dart';
import 'package:scan_quest_app/screens/chat_screen.dart';
import 'package:scan_quest_app/screens/inventory_screen.dart';
import 'package:scan_quest_app/screens/scan_screen.dart';
import 'package:scan_quest_app/utilities/constants.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static const String id = 'main_screen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // To track the selected index
  final PageController _pageController = PageController(initialPage: 1);
  final List<Widget> _screens = const [
    ChatScreen(),
    InventoryScreen(),
    ScanScreen(),
  ];

  // Function to handle BottomNavigationBar tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kSecondaryColor,
        title: const Text("ScanQuest"),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('icons/chat.png'),
            ),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('icons/home.png'),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('icons/scan.png'),
            ),
            label: "Scan",
          ),
        ],
      ),
    );
  }
}
