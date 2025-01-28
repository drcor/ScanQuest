import 'package:flutter/cupertino.dart';
import 'package:scan_quest_app/database/treasure_items_table.dart';
import 'package:scan_quest_app/models/treasure_items_model.dart';

class TreasureItemsProvider with ChangeNotifier {
  List<TreasureItem> _items = [];

  /// Get the list of items
  List<TreasureItem> get items => _items;

  /// Update the list of items
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

  /// Reset the items to the initial state as not found
  Future<void> resetItems() async {
    await TreasureItemsDatabase.instance.resetCollected();

    await updateItems();
  }
}
