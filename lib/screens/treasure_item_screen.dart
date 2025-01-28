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
  bool _isTradingItem = false;

  /// Set the trading state to true
  void _isTrading() {
    setState(() {
      _isTradingItem = true;
    });
  }

  /// Set the trading state to false
  void _isNotTrading() {
    setState(() {
      _isTradingItem = false;
    });
  }

  /// Trade the item with the other device
  void _tradeItem() async {
    // Prevent multiple trading
    if (_isTradingItem) {
      return;
    }

    final flutterP2pConnectionPlugin =
        Provider.of<FlutterP2PConnectionProvider>(context, listen: false)
            .flutterP2pConnectionPlugin;

    _isTrading();

    // Send the NFC ID to the other device
    flutterP2pConnectionPlugin
        .sendStringToSocket("\x00\x01${widget.item.nfcId}");

    _isNotTrading();
  }

  /// Get the formatted [date] string as 'yyyy-MM-dd HH:mm:ss'
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
    // Listen to the item sent event
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If the item is sent, close the screen
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
                  _isTradingItem ? kSecondaryColor : kPrimaryColor,
                ),
              ),
              child: Text(_isTradingItem ? 'Cancel trading' : 'Trade Item'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
