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

  WifiP2PInfo? wifiP2PInfo;
  List<DiscoveredPeers> peers = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() async {
    final flutterP2pConnectionProvider =
        Provider.of<FlutterP2PConnectionProvider>(context, listen: false);

    await flutterP2pConnectionProvider.init();

    flutterP2pConnectionProvider.flutterP2pConnectionPlugin
        .streamWifiP2PInfo()
        .listen((event) {
      if (!mounted) return;
      setState(() {
        wifiP2PInfo = event;
      });

      if (wifiP2PInfo != null && wifiP2PInfo!.isConnected) {
        if (wifiP2PInfo!.isGroupOwner) {
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
        peers = event;
      });
    });

    // Start discovering nearby devices
    bool? discovering = await flutterP2pConnectionProvider
        .flutterP2pConnectionPlugin
        .discover();
    if (discovering) snack("Discovering nearby devices");
  }

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

  void _receiveItem(String res) async {
    final flutterP2pConnectionPlugin =
        Provider.of<FlutterP2PConnectionProvider>(context, listen: false)
            .flutterP2pConnectionPlugin;

    await TreasureItemsDatabase.instance.readByNfcId(res).then((value) {
      if (value != null) {
        if (!value.isFound) {
          // send an ACK to the sender
          flutterP2pConnectionPlugin.sendStringToSocket(
            "\x00\x06${value.nfcId}",
          );
          // update the item as found
          value.isFound = true;
          value.collectedOn = DateTime.now();
          TreasureItemsDatabase.instance.update(value);
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

  void _finalizeTrade(String res) async {
    await TreasureItemsDatabase.instance.readByNfcId(res).then((value) {
      if (value != null) {
        if (value.isFound) {
          value.isFound = false;
          TreasureItemsDatabase.instance.update(value);
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

  void _onCloseSocket(FlutterP2pConnection flutterP2pConnectionPlugin) {
    flutterP2pConnectionPlugin.closeSocket();
    flutterP2pConnectionPlugin.disconnect();
    snack("Disconnected from remote device");
  }

  Future startSocket() async {
    final flutterP2pConnectionPlugin =
        Provider.of<FlutterP2PConnectionProvider>(context, listen: false)
            .flutterP2pConnectionPlugin;

    if (wifiP2PInfo != null) {
      await flutterP2pConnectionPlugin.startSocket(
        groupOwnerAddress: wifiP2PInfo!.groupOwnerAddress,
        downloadPath: "/storage/emulated/0/Download/",
        maxConcurrentDownloads: 2,
        deleteOnError: true,
        onConnect: (name, address) {
          snack("$name connected with address: $address");
        },
        transferUpdate: (transfer) {
          // if (transfer.completed) {
          //   snack(
          //       "${transfer.failed ? "failed to ${transfer.receiving ? "receive" : "send"}" : transfer.receiving ? "received" : "sent"}: ${transfer.filename}");
          // }
          // print(
          //     "ID: ${transfer.id}, FILENAME: ${transfer.filename}, PATH: ${transfer.path}, COUNT: ${transfer.count}, TOTAL: ${transfer.total}, COMPLETED: ${transfer.completed}, FAILED: ${transfer.failed}, RECEIVING: ${transfer.receiving}");
        },
        onCloseSocket: () {
          _onCloseSocket(flutterP2pConnectionPlugin);
        },
        receiveString: _handleString,
      );
      // snack("open socket: $started");
    }
  }

  Future connectToSocket() async {
    final flutterP2pConnectionPlugin =
        Provider.of<FlutterP2PConnectionProvider>(context, listen: false)
            .flutterP2pConnectionPlugin;

    if (wifiP2PInfo != null) {
      await flutterP2pConnectionPlugin.connectToSocket(
        groupOwnerAddress: wifiP2PInfo!.groupOwnerAddress,
        downloadPath: "/storage/emulated/0/Download/",
        maxConcurrentDownloads: 3,
        deleteOnError: true,
        onConnect: (address) {
          snack("Connected to socket: $address");
        },
        onCloseSocket: () {
          _onCloseSocket(flutterP2pConnectionPlugin);
        },
        transferUpdate: (transfer) {
          // if (transfer.count == 0) transfer.cancelToken?.cancel();
          // if (transfer.completed) {
          //   snack(
          //       "${transfer.failed ? "failed to ${transfer.receiving ? "receive" : "send"}" : transfer.receiving ? "received" : "sent"}: ${transfer.filename}");
          // }
          // print(
          //     "ID: ${transfer.id}, FILENAME: ${transfer.filename}, PATH: ${transfer.path}, COUNT: ${transfer.count}, TOTAL: ${transfer.total}, COMPLETED: ${transfer.completed}, FAILED: ${transfer.failed}, RECEIVING: ${transfer.receiving}");
        },
        receiveString: _handleString,
      );
    }
  }

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

  Future sendMessage() async {
    final flutterP2pConnectionPlugin =
        Provider.of<FlutterP2PConnectionProvider>(context, listen: false)
            .flutterP2pConnectionPlugin;
    flutterP2pConnectionPlugin.sendStringToSocket(_msgTextController.text);
  }

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
          // Text(
          //   "IP: ${wifiP2PInfo == null ? "null" : wifiP2PInfo?.groupOwnerAddress}",
          // ),
          // wifiP2PInfo != null
          //     ? Text(
          //         "connected: ${wifiP2PInfo?.isConnected}, isGroupOwner: ${wifiP2PInfo?.isGroupOwner}, groupFormed: ${wifiP2PInfo?.groupFormed}, clients: ${wifiP2PInfo?.clients}")
          //     //"connected: ${wifiP2PInfo?.isConnected}, isGroupOwner: ${wifiP2PInfo?.isGroupOwner}, groupFormed: ${wifiP2PInfo?.groupFormed}, groupOwnerAddress: ${wifiP2PInfo?.groupOwnerAddress}, clients: ${wifiP2PInfo?.clients}")
          //     : const SizedBox.shrink(),
          const SizedBox(height: 10),
          const Text("Devices:"),
          SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: peers.length,
                itemBuilder: (context, index) {
                  bool isServiceDiscoveryCapable =
                      peers[index].isServiceDiscoveryCapable;
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
                                    Text(peers[index].deviceName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
                                    Text(
                                        "Address: ${peers[index].deviceAddress}"),
                                    // Text(
                                    //     "isGroupOwner: ${peers[index].isGroupOwner}"),
                                    // Text(
                                    //     "isServiceDiscoveryCapable: ${peers[index].isServiceDiscoveryCapable}"),
                                    // Text(
                                    //     "primaryDeviceType: ${peers[index].primaryDeviceType}"),
                                    // Text(
                                    //     "secondaryDeviceType: ${peers[index].secondaryDeviceType}"),
                                    // Text("status: ${peers[index].status}"),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    bool? bo = await flutterP2pConnectionPlugin
                                        .connect(peers[index].deviceAddress);
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
                            peers[index]
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
          // ElevatedButton(
          //   onPressed: () async {
          //     snack(await flutterP2pConnectionPlugin.askStoragePermission()
          //         ? "granted"
          //         : "denied");
          //   },
          //   child: const Text("ask storage permission"),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     snack(await flutterP2pConnectionPlugin.askConnectionPermissions()
          //         ? "granted"
          //         : "denied");
          //   },
          //   child: const Text(
          //     "ask required permissions for connection (nearbyWifiDevices & location)",
          //     textAlign: TextAlign.center,
          //   ),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     snack(await flutterP2pConnectionPlugin.checkLocationEnabled()
          //         ? "enabled"
          //         : "disabled");
          //   },
          //   child: const Text(
          //     "check location enabled",
          //   ),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     snack(await flutterP2pConnectionPlugin.checkWifiEnabled()
          //         ? "enabled"
          //         : "disabled");
          //   },
          //   child: const Text("check wifi enabled"),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     print(await flutterP2pConnectionPlugin.enableLocationServices());
          //   },
          //   child: const Text("enable location"),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     print(await flutterP2pConnectionPlugin.enableWifiServices());
          //   },
          //   child: const Text("enable wifi"),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     bool? created = await flutterP2pConnectionPlugin.createGroup();
          //     snack("created group: $created");
          //   },
          //   child: const Text("create group"),
          // ),
          ElevatedButton(
            onPressed: () async {
              flutterP2pConnectionPlugin.closeSocket();
              bool? removed = await flutterP2pConnectionPlugin.removeGroup();
              if (removed) snack("Disconnected from remote device");
            },
            child: const Text("Disconnect"),
          ),
          // ElevatedButton(
          //   onPressed: () async {
          //     var info = await flutterP2pConnectionPlugin.groupInfo();
          //     showDialog(
          //       context: context,
          //       builder: (context) => Center(
          //         child: Dialog(
          //           child: SizedBox(
          //             height: 200,
          //             child: Padding(
          //               padding: const EdgeInsets.symmetric(horizontal: 10),
          //               child: Column(
          //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text("groupNetworkName: ${info?.groupNetworkName}"),
          //                   Text("passPhrase: ${info?.passPhrase}"),
          //                   Text("isGroupOwner: ${info?.isGroupOwner}"),
          //                   Text("clients: ${info?.clients}"),
          //                 ],
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     );
          //   },
          //   child: const Text("get group info"),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     String? ip = await flutterP2pConnectionPlugin.getIPAddress();
          //     snack("ip: $ip");
          //   },
          //   child: const Text("get ip"),
          // ),
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
          // ElevatedButton(
          //   onPressed: () async {
          //     startSocket();
          //   },
          //   child: const Text("open a socket"),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     connectToSocket();
          //   },
          //   child: const Text("connect to socket"),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     closeSocketConnection();
          //   },
          //   child: const Text("close socket"),
          // ),
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
