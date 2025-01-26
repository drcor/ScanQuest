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

    Future.microtask(() => setup());

    // Avoid NFC pop-up
    // NfcManager.instance.startSession(
    //   onDiscovered: (NfcTag tag) async {},
    // );
  }

  @override
  void dispose() {
    // NfcManager.instance.stopSession();
    super.dispose();
  }

  Future<void> setup() async {
    Provider.of<TreasureItemsProvider>(context, listen: false).updateItems();
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
                            // if the item is traded, update the items
                            if (value != null && value) {
                              provider.updateItems();
                              if (mounted) {
                                Helper.showAlertDialog(
                                  ctx,
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
