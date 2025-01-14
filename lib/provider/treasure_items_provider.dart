import 'package:flutter/cupertino.dart';
import 'package:scan_quest_app/database/treasure_items_connection_table.dart';
import 'package:scan_quest_app/models/treasure_items_connection_model.dart';

class TreasureItemsProvider with ChangeNotifier {
  List<TreasureItem> _items = [];

  List<TreasureItem> get items => _items;

  Future<void> updateItems() async {
    List<TreasureItem>? tempItems =
        await TreasureItemsDatabase.instance.readAllCollected();
    if (tempItems != null) {
      _items = tempItems;
    } else {
      _items = [];
    }
    notifyListeners();
  }
}
