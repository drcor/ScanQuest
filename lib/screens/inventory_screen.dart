import 'package:flutter/material.dart';
import 'package:scan_quest_app/database/items_connection_table.dart';
import 'package:scan_quest_app/models/items_connection_model.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  static List<TreasureItem> items = [];

  @override
  void initState() {
    super.initState();

    setup();
  }

  void setup() async {
    List<TreasureItem>? tempItems =
        await TreasureItemsDatabase.instance.readAll();

    if (tempItems != null) {
      setState(() {
        items = tempItems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "My Items",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
              // childAspectRatio: 3 / 2,
              crossAxisSpacing: 4,
            ),
            itemCount: items.length,
            itemBuilder: (BuildContext ctx, index) {
              return TextButton(
                onPressed: () {},
                child: Image.asset(
                  'images/${items[index].image}.png',
                  fit: BoxFit.fitHeight,
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
