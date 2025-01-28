import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'package:provider/provider.dart';
import 'package:scan_quest_app/database/treasure_items_table.dart';
import 'package:scan_quest_app/provider/flutter_p2p_connection_provider.dart';
import 'package:scan_quest_app/provider/treasure_items_provider.dart';
import 'package:scan_quest_app/provider/user_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin<ChatScreen> {
  final TextEditingController _msgTextController = TextEditingController();

  WifiP2PInfo? _wifiP2PInfo;
  List<DiscoveredPeers> _peers = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _init();
  }

  /// Initialize the FlutterP2PConnection plugin and start discovering nearby devices
  void _init() async {
    final flutterP2pConnectionProvider =
        Provider.of<FlutterP2PConnectionProvider>(context, listen: false);

    await flutterP2pConnectionProvider.init();

    flutterP2pConnectionProvider.flutterP2pConnectionPlugin
        .streamWifiP2PInfo()
        .listen((event) {
      if (!mounted) return;
      setState(() {
        _wifiP2PInfo = event;
      });

      if (_wifiP2PInfo != null && _wifiP2PInfo!.isConnected) {
        if (_wifiP2PInfo!.isGroupOwner) {
          startSocket();
        } else {
          connectToSocket();
        }
      }
    });
    flutterP2pConnectionProvider.flutterP2pConnectionPlugin
        .streamPeers()
        .listen((event) {
      if (!mounted) return;
      setState(() {
        _peers = event;
      });
    });

    // Start discovering nearby devices
    bool? discovering = await flutterP2pConnectionProvider
        .flutterP2pConnectionPlugin
        .discover();
    if (discovering) snack("Discovering nearby devices");
  }

  /// Handle the received message
  void _handleString(dynamic req) {
    // if the message is a received nfcId
    if (req.startsWith("\x00\x01")) {
      String res = req.substring(2);
      _receiveItem(res);
    }
    // if the message is an ACK of a sended nfc id
    else if (req.startsWith("\x00\x06")) {
      String res = req.substring(2);
      _finalizeTrade(res);
    } else {
      snack(req);
    }
  }

  /// Receive the item and send an ACK to the sender
  void _receiveItem(String res) async {
    final flutterP2pConnectionPlugin =
        Provider.of<FlutterP2PConnectionProvider>(context, listen: false)
            .flutterP2pConnectionPlugin;

    await TreasureItemsDatabase.instance.readByNfcId(res).then((value) async {
      if (value != null) {
        if (!value.isFound) {
          // send an ACK to the sender
          flutterP2pConnectionPlugin.sendStringToSocket(
            "\x00\x06${value.nfcId}",
          );
          // update the item as found
          value.isFound = true;
          value.collectedOn = DateTime.now();
          await TreasureItemsDatabase.instance.update(value);
          // update the items list
          if (mounted) {
            Provider.of<TreasureItemsProvider>(context, listen: false)
                .updateItems();
            // Add half the experience of the item to the user
            Provider.of<UserProvider>(context, listen: false)
                .addExperience(value.experience ~/ 2);
          }
        }
      }
    });
  }

  /// Finalize the trade by updating the item as not found
  void _finalizeTrade(String res) async {
    await TreasureItemsDatabase.instance.readByNfcId(res).then((value) async {
      if (value != null) {
        if (value.isFound) {
          value.isFound = false;
          await TreasureItemsDatabase.instance.update(value);
          // update the items list
          if (mounted) {
            Provider.of<FlutterP2PConnectionProvider>(context, listen: false)
                .isItemSent = true;
            Provider.of<TreasureItemsProvider>(context, listen: false)
                .updateItems();
            // Add half the experience of the item to the user
            Provider.of<UserProvider>(context, listen: false)
                .addExperience(value.experience ~/ 2);
          }
        }
      }
    });
  }

  /// Handle the close socket event
  void _onCloseSocket(FlutterP2pConnection flutterP2pConnectionPlugin) {
    flutterP2pConnectionPlugin.closeSocket();
    flutterP2pConnectionPlugin.disconnect();
    snack("Disconnected from remote device");
  }

  /// Start a socket connection
  Future<void> startSocket() async {
    final flutterP2pConnectionPlugin =
        Provider.of<FlutterP2PConnectionProvider>(context, listen: false)
            .flutterP2pConnectionPlugin;

    if (_wifiP2PInfo != null) {
      await flutterP2pConnectionPlugin.startSocket(
        groupOwnerAddress: _wifiP2PInfo!.groupOwnerAddress,
        downloadPath: "/storage/emulated/0/Download/",
        maxConcurrentDownloads: 2,
        deleteOnError: true,
        onConnect: (name, address) {
          snack("$name connected with address: $address");
        },
        transferUpdate: (transfer) {},
        onCloseSocket: () {
          _onCloseSocket(flutterP2pConnectionPlugin);
        },
        receiveString: _handleString,
      );
    }
  }

  /// Connect to a socket
  Future<void> connectToSocket() async {
    final flutterP2pConnectionPlugin =
        Provider.of<FlutterP2PConnectionProvider>(context, listen: false)
            .flutterP2pConnectionPlugin;

    if (_wifiP2PInfo != null) {
      await flutterP2pConnectionPlugin.connectToSocket(
        groupOwnerAddress: _wifiP2PInfo!.groupOwnerAddress,
        downloadPath: "/storage/emulated/0/Download/",
        maxConcurrentDownloads: 3,
        deleteOnError: true,
        onConnect: (address) {
          snack("Connected to socket: $address");
        },
        onCloseSocket: () {
          _onCloseSocket(flutterP2pConnectionPlugin);
        },
        transferUpdate: (transfer) {},
        receiveString: _handleString,
      );
    }
  }

  /// Close the socket connection
  Future closeSocketConnection() async {
    final flutterP2pConnectionPlugin =
        Provider.of<FlutterP2PConnectionProvider>(context, listen: false)
            .flutterP2pConnectionPlugin;

    bool closed = flutterP2pConnectionPlugin.closeSocket();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Closed: $closed",
        ),
      ),
    );
  }

  /// Send a message to the connected device
  Future sendMessage() async {
    final flutterP2pConnectionPlugin =
        Provider.of<FlutterP2PConnectionProvider>(context, listen: false)
            .flutterP2pConnectionPlugin;
    flutterP2pConnectionPlugin.sendStringToSocket(_msgTextController.text);
  }

  /// Show a snack bar message at the bottom of the screen
  void snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          msg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final flutterP2pConnectionPlugin =
        Provider.of<FlutterP2PConnectionProvider>(context)
            .flutterP2pConnectionPlugin;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const Text("Devices:"),
          SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _peers.length,
                itemBuilder: (context, index) {
                  bool isServiceDiscoveryCapable =
                      _peers[index].isServiceDiscoveryCapable;
                  if (isServiceDiscoveryCapable == false) {
                    return SizedBox.shrink();
                  }
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Center(
                            child: AlertDialog(
                              content: SizedBox(
                                height: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_peers[index].deviceName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
                                    Text(
                                        "Address: ${_peers[index].deviceAddress}"),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    bool? bo = await flutterP2pConnectionPlugin
                                        .connect(_peers[index].deviceAddress);
                                    if (bo) snack("Connected: $bo");
                                  },
                                  child: const Text("Connect"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            _peers[index]
                                .deviceName
                                .toString()
                                .characters
                                .first
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
          ElevatedButton(
            onPressed: () async {
              flutterP2pConnectionPlugin.closeSocket();
              bool? removed = await flutterP2pConnectionPlugin.removeGroup();
              if (removed) snack("Disconnected from remote device");
            },
            child: const Text("Disconnect"),
          ),
          ElevatedButton(
            onPressed: () async {
              bool? discovering = await flutterP2pConnectionPlugin.discover();
              if (discovering) snack("Discovering nearby devices");
            },
            child: const Text("Discover"),
          ),
          ElevatedButton(
            onPressed: () async {
              bool? stopped = await flutterP2pConnectionPlugin.stopDiscovery();
              if (stopped) snack("Stopped discovering");
            },
            child: const Text("Stop discovery"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgTextController,
                    decoration: const InputDecoration(
                      hintText: "Message",
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    sendMessage();
                  },
                  child: const Text("Send"),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }
}
