import 'package:flutter/material.dart';

class Helper {
  /// Show an alert dialog with the given [title] and [message]
  static void showAlert(
    BuildContext context,
    String title,
    String message,
  ) {
    // Show the alert dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
