import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scan_quest_app/provider/treasure_items_provider.dart';
import 'package:scan_quest_app/screens/treasure_item_screen.dart';
import 'package:scan_quest_app/utilities/helper.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({
    super.key,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() => _setup());
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Setup the inventory screen
  Future<void> _setup() async {
    await Provider.of<TreasureItemsProvider>(context, listen: false)
        .updateItems();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TreasureItemsProvider>(builder: (context, provider, child) {
      return Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "My Items",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Expanded(
            child: provider.items.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No items in the collection'),
                    ],
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      // childAspectRatio: 3 / 2,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: provider.items.length,
                    itemBuilder: (BuildContext ctx, index) {
                      return TextButton(
                        onPressed: () {
                          Navigator.of(ctx)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => ItemScreen(
                                item: provider.items[index],
                              ),
                            ),
                          )
                              .then((value) {
                            // If the item is traded, update the items
                            if (value != null && value) {
                              provider.updateItems();
                              if (mounted) {
                                Helper.showAlert(
                                  context,
                                  'Success',
                                  'Item traded successfully',
                                );
                              }
                            }
                          });
                        },
                        child: Image.asset(
                          'images/${provider.items[index].image}.png',
                          fit: BoxFit.contain,
                          height: 150,
                          filterQuality: FilterQuality.none,
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}
