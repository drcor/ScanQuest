import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scan_quest_app/models/treasure_items_model.dart';
import 'package:scan_quest_app/provider/flutter_p2p_connection_provider.dart';
import 'package:scan_quest_app/utilities/constants.dart';

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

  void _tradeItem() async {
    final flutterP2pConnectionPlugin =
        Provider.of<FlutterP2PConnectionProvider>(context, listen: false)
            .flutterP2pConnectionPlugin;

    _isWriting();

    flutterP2pConnectionPlugin
        .sendStringToSocket("\x00\x01${widget.item.nfcId}");

    _isNotWriting();

    /*
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
    */
  }

  String _getDateFormatted(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');
    String seconds = date.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // update the items list
    final flutterP2pConnectionPlugin =
        Provider.of<FlutterP2PConnectionProvider>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (flutterP2pConnectionPlugin.isItemSent) {
        flutterP2pConnectionPlugin.isItemSent = false;
        Navigator.of(context).pop(true);
      }
    });

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
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: kItemTitleStyle,
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
                style: kItemTitleStyle,
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
                style: kItemTitleStyle,
                children: <TextSpan>[
                  TextSpan(
                    text: 'Collected on: ',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: _getDateFormatted(widget.item.collectedOn),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            FilledButton(
              onPressed: _tradeItem,
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
