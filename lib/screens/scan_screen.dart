import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:scan_quest_app/utilities/constants.dart';
import 'package:scan_quest_app/utilities/helper.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: () async {
          // Check availability
          bool isAvailable = await NfcManager.instance.isAvailable();

          if (!isAvailable) {
            Helper.showAlertDialog(context, 'Alert', 'NFC is not available');
            return;
          }
          // Start Session
          NfcManager.instance.startSession(
            onDiscovered: (NfcTag tag) async {
              // Do something with an NfcTag instance.
            },
          );

          // Stop Session
          NfcManager.instance.stopSession();
        },
        child: Text("Scan NFC tag"),
      ),
    );
  }
}
