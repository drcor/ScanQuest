import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:scan_quest_app/database/treasure_items_connection_table.dart';
import 'package:scan_quest_app/models/treasure_items_connection_model.dart';
import 'package:scan_quest_app/utilities/constants.dart';
import 'package:scan_quest_app/utilities/helper.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({
    super.key,
    required this.item,
  });

  final TreasureItem item;

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  bool isWriting = false;

  void _isWriting() {
    setState(() {
      isWriting = true;
    });
  }

  void _isNotWriting() {
    setState(() {
      isWriting = false;
    });
  }

  void _ndefWrite() {
    if (isWriting) {
      NfcManager.instance.stopSession();
      _isNotWriting();
      return;
    }

    _isWriting();
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        Helper.showAlertDialog(context, 'Alert', 'Tag is not ndef writable');
        NfcManager.instance
            .stopSession(errorMessage: 'Tag is not ndef writable');
        return;
      }

      NdefMessage message = NdefMessage([
        NdefRecord.createText(widget.item.nfcId),
      ]);

      try {
        await ndef.write(message);
        NfcManager.instance.stopSession();

        // Update the item as not collected
        widget.item.isFound = false;
        await TreasureItemsDatabase.instance.update(widget.item);
      } catch (e) {
        if (mounted) {
          Helper.showAlertDialog(context, 'Error', e.toString());
        }
        NfcManager.instance.stopSession(errorMessage: e.toString());
        _isNotWriting();
        return;
      }

      _isNotWriting();

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: Image.asset(
                      'images/${widget.item.image}.png',
                      fit: BoxFit.contain,
                      scale: 1.5,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                  Text(
                    widget.item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: Theme.of(context).textTheme.bodyMedium,
                children: <TextSpan>[
                  TextSpan(
                    text: 'NFC ID: ',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: widget.item.nfcId,
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: Theme.of(context).textTheme.bodyMedium,
                children: <TextSpan>[
                  TextSpan(
                    text: 'Description: ',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: widget.item.description,
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: Theme.of(context).textTheme.bodyMedium,
                children: <TextSpan>[
                  TextSpan(
                    text: 'Collected on: ',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: widget.item.collectedOn.toIso8601String(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            FilledButton(
              onPressed: _ndefWrite,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  isWriting ? kSecondaryColor : kPrimaryColor,
                ),
              ),
              child: Text(isWriting ? 'Cancel trading' : 'Trade Item'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
