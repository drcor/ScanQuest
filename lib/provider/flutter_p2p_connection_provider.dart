import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class FlutterP2PConnectionProvider with ChangeNotifier {
  final FlutterP2pConnection _flutterP2pConnectionPlugin =
      FlutterP2pConnection();

  bool itemSent = false;

  FlutterP2pConnection get flutterP2pConnectionPlugin =>
      _flutterP2pConnectionPlugin;

  bool get isItemSent => itemSent;

  set isItemSent(bool value) {
    itemSent = value;
    notifyListeners();
  }

  Future<void> checkPermissions() async {
    // check if storage permission is granted
    if (!await FlutterP2pConnection().checkStoragePermission()) {
      // request storage permission
      await FlutterP2pConnection().askStoragePermission();
    }
    // check if location is enabled
    if (!await FlutterP2pConnection().checkLocationEnabled()) {
      // enable location
      FlutterP2pConnection().enableLocationServices();
    }
    // check if wifi is enabled
    if (!await FlutterP2pConnection().checkWifiEnabled()) {
      // enable wifi
      await FlutterP2pConnection().enableWifiServices();
    }
    // ask all permissions required for group creation and connections (nearbyWifiDevices & location)
    await FlutterP2pConnection().askConnectionPermissions();
  }

  Future<void> init() async {
    await _flutterP2pConnectionPlugin.initialize();
    await _flutterP2pConnectionPlugin.register();

    notifyListeners();
  }
}
