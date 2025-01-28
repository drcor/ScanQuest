import 'package:flutter/material.dart';
import 'package:scan_quest_app/database/user_table.dart';
import 'package:scan_quest_app/models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? user;
  final _userNotFound = Exception(
      'User not found. Please delete the app storage and restart the app');

  /// Setup the user provider by getting the user from the database
  Future<void> setup() async {
    // Get the user name from the database
    user = await UserDatabase.instance.getUser();
    if (user == null) {
      throw _userNotFound;
    } else {
      notifyListeners();
    }
  }

  /// Get the user name initials
  ///
  /// Return the initials of the user name if found, otherwise an empty string
  String getUserInitials() {
    if (user == null) {
      return '';
    }
    return user!.name.split(' ').map((e) => e[0]).join().toUpperCase();
  }

  /// Update the user name with [name]
  Future<void> updateName(String name) async {
    if (user == null) {
      throw _userNotFound;
    } else {
      user?.name = name;
      _updateModifiedTime();

      user = await UserDatabase.instance.update(user!);
      notifyListeners();
    }
  }

  /// Add the [experience] to the user
  Future<void> addExperience(int experience) async {
    if (user == null) {
      throw _userNotFound;
    } else {
      user?.experience += experience;
      _updateModifiedTime();

      user = await UserDatabase.instance.update(user!);
      notifyListeners();
    }
  }

  /// Update the user last modification time
  void _updateModifiedTime() {
    if (user != null) {
      user?.lastModification = DateTime.now();
    }
  }

  /// Reset the user to the default values
  Future<void> resetUser() async {
    await UserDatabase.instance.resetUser();
    await setup();
  }
}
