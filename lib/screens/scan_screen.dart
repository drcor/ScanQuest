import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';
import 'package:scan_quest_app/database/treasure_items_table.dart';
import 'package:scan_quest_app/models/treasure_items_model.dart';
import 'package:scan_quest_app/provider/treasure_items_provider.dart';
import 'package:scan_quest_app/provider/user_provider.dart';
import 'package:scan_quest_app/utilities/helper.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  TreasureItem? item;
  bool isNFCAvailable = false;

  @override
  void initState() {
    super.initState();
    _startNfcReader();
  }

  @override
  void dispose() {
    if (isNFCAvailable) NfcManager.instance.stopSession();
    super.dispose();
  }

  /// Start the NFC reader to scan the items
  /// If the item is found, update the item as found and add experience to the user
  /// Show an alert dialog if the item is not found
  void _startNfcReader() async {
    // Check availability of NFC
    NfcManager.instance.isAvailable().then((isAvailable) {
      if (!isAvailable) {
        if (mounted) {
          Helper.showAlert(context, 'Alert', 'NFC is not available');
        }
        return;
      }
      setState(() {
        isNFCAvailable = true;
      });

      // Start the NFC session
      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        Ndef? ndef = Ndef.from(tag);

        if (ndef == null || ndef.cachedMessage == null) {
          if (mounted) {
            Helper.showAlert(
              context,
              'Alert',
              'Tag don\'t contain an item',
            ); // Tag is not compatible with NDEF or don't have NDEF message
          }
          return;
        }

        // Read the NDEF message
        NdefMessage ndefMessage = ndef.cachedMessage!;
        NdefRecord ndefRecord = ndefMessage.records.first;

        // Get the payload from the NDEF record
        String payload = String.fromCharCodes(
          ndefRecord.payload.sublist(ndefRecord.payload[0] + 1),
        );

        // Read the item from the database
        item = await TreasureItemsDatabase.instance.readByNfcId(payload);
        setState(() {});

        // If the item is not found, update the item as found
        if (item != null && item!.isFound == false) {
          item!.collectedOn = DateTime.now();
          item!.isFound = true;
          await TreasureItemsDatabase.instance.update(item!);
          TreasureItem? tmp =
              await TreasureItemsDatabase.instance.readByNfcId(payload);

          if (mounted) {
            // Add experience to the user
            Provider.of<UserProvider>(context, listen: false)
                .addExperience(item!.experience);

            Helper.showAlert(
              context,
              'New item discovered',
              '${tmp!.name} was found',
            );

            Provider.of<TreasureItemsProvider>(context, listen: false)
                .updateItems();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Scan the items NFC tag"),
          SizedBox(height: 20),
          Text(
            item?.name ?? "Scanning for items...",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          item?.name != null
              ? Image.asset(
                  'images/${item!.image}.png',
                  fit: BoxFit.contain,
                  height: 150,
                  filterQuality: FilterQuality.none,
                )
              : const SizedBox(
                  height: 150,
                ),
        ],
      ),
    );
  }
}
