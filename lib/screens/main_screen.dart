import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scan_quest_app/provider/flutter_p2p_connection_provider.dart';
import 'package:scan_quest_app/provider/user_provider.dart';
import 'package:scan_quest_app/screens/chat_screen.dart';
import 'package:scan_quest_app/screens/inventory_screen.dart';
import 'package:scan_quest_app/screens/scan_screen.dart';
import 'package:scan_quest_app/screens/user_screen.dart';
import 'package:scan_quest_app/utilities/constants.dart';
import 'package:scan_quest_app/utilities/helper.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static const String id = 'main_screen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // To track the selected index
  final PageController _pageController = PageController(initialPage: 1);

  @override
  void initState() {
    super.initState();

    final flutterP2pConnectionProvider =
        Provider.of<FlutterP2PConnectionProvider>(context, listen: false);
    _setup(flutterP2pConnectionProvider);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _setup(FlutterP2PConnectionProvider flutterP2pConnectionProvider) async {
    Provider.of<UserProvider>(context, listen: false).setup();
    await flutterP2pConnectionProvider.checkPermissions();
  }

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
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kSecondaryColor,
        title: const Text(
          "ScanQuest",
          style: TextStyle(color: kDetailsColor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (userProvider.user == null) {
                Helper.showAlertDialog(
                  context,
                  'Error',
                  'User not found.\nPlease delete the app storage and restart the app.\nYou will lose all your progress.',
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserScreen(),
                ),
              );
            },
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(kDetailsColor),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: const BorderSide(color: kDetailsColor),
                ),
              ),
            ),
            child: Text(userProvider.getUserInitials()),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          ChatScreen(),
          InventoryScreen(),
          ScanScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: kSecondaryColor,
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
