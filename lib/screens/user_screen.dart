import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scan_quest_app/provider/treasure_items_provider.dart';
import 'package:scan_quest_app/utilities/constants.dart';
import 'package:scan_quest_app/provider/user_provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  static const String id = 'user_screen';

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool canSave = false;

  @override
  void initState() {
    super.initState();

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    _usernameController.addListener(_onTextChanged);
    setState(() {
      _usernameController.text = userProvider.user?.name ?? '';
    });
  }

  void _canSave() {
    setState(() {
      canSave = true;
    });
  }

  void _cannotSave() {
    setState(() {
      canSave = false;
    });
  }

  void _onTextChanged() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_usernameController.text.isEmpty ||
        _usernameController.text == userProvider.user?.name) {
      _cannotSave();
      return;
    }
    _canSave();
  }

  void _saveChanges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_usernameController.text.isEmpty ||
        _usernameController.text == userProvider.user?.name) {
      return;
    }

    await userProvider.updateName(_usernameController.text);
    // widget.callbackOnSaveChanges();

    _cannotSave();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Configurations",
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: Text(
                      "${userProvider.user?.experience ?? 0} XP",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "User name:",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextField(
                    controller: _usernameController,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: const InputDecoration(
                      hintText: 'Enter your username',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kDetailsColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: kSecondaryColor, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Center(
                child: FilledButton(
                  onPressed: canSave ? _saveChanges : null,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      canSave ? kPrimaryColor : kSecondaryColor,
                    ),
                  ),
                  child: Text("Save Changes"),
                ),
              ),
              SizedBox(height: 200),
              FilledButton(
                onPressed: () async {
                  bool deleteData = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete all data'),
                        content: Text(
                            "Are you really sure you want to delete all data?"),
                        actions: [
                          TextButton(
                            child: Text("Yes"),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (!deleteData) {
                    return;
                  }

                  if (mounted) {
                    Provider.of<TreasureItemsProvider>(context, listen: false)
                        .resetItems();
                    userProvider.resetUser();
                    Navigator.pop(context);
                  }
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(kAlertColor),
                ),
                child: Text("Delete all data"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
