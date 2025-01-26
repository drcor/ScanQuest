import 'package:flutter/material.dart';
import 'package:scan_quest_app/database/user_table.dart';
import 'package:scan_quest_app/models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? user;
  final userNotFound = Exception(
      'User not found. Please delete the app storage and restart the app');

  Future<void> setup() async {
    // Get the user name from the database
    user = await UserDatabase.instance.getUser();
    if (user == null) {
      throw userNotFound;
    } else {
      notifyListeners();
    }
  }

  String getUserInitials() {
    if (user == null) {
      return '';
    }
    return user!.name.split(' ').map((e) => e[0]).join().toUpperCase();
  }

  Future<void> updateName(String name) async {
    if (user == null) {
      throw userNotFound;
    } else {
      user?.name = name;
      _updateModifiedTime();

      await UserDatabase.instance.update(user!);
      notifyListeners();
    }
  }

  Future<void> addExperience(int experience) async {
    if (user == null) {
      throw userNotFound;
    } else {
      user?.experience += experience;
      _updateModifiedTime();

      await UserDatabase.instance.update(user!);
      notifyListeners();
    }
  }

  void _updateModifiedTime() {
    if (user != null) {
      user?.lastModification = DateTime.now();
    }
  }
}
