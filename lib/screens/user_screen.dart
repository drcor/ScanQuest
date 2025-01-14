import 'package:flutter/material.dart';
import 'package:scan_quest_app/database/user_table.dart';
import 'package:scan_quest_app/models/user_model.dart';
import 'package:scan_quest_app/utilities/constants.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({
    super.key,
    required this.user,
    required this.callback,
  });

  static const String id = 'user_screen';

  final User user;
  final VoidCallback callback;

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool canSave = false;

  @override
  void initState() {
    super.initState();

    _usernameController.addListener(_onTextChanged);
    setState(() {
      _usernameController.text = widget.user.name;
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
    if (_usernameController.text.isEmpty ||
        _usernameController.text == widget.user.name) {
      _cannotSave();
      return;
    }
    _canSave();
  }

  void _saveChanges() async {
    if (_usernameController.text.isEmpty ||
        _usernameController.text == widget.user.name) {
      return;
    }

    widget.user.name = _usernameController.text;
    widget.user.lastModification = DateTime.now();
    await UserDatabase.instance.update(widget.user);
    widget.callback();

    _cannotSave();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "User name:",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextField(
                    controller: _usernameController,
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
            ],
          ),
        ),
      ),
    );
  }
}
