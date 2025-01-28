import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class FlutterP2PConnectionProvider with ChangeNotifier {
  final FlutterP2pConnection _flutterP2pConnectionPlugin =
      FlutterP2pConnection();

  bool _itemSent = false;

  /// Get the FlutterP2pConnection instance
  FlutterP2pConnection get flutterP2pConnectionPlugin =>
      _flutterP2pConnectionPlugin;

  /// Check if the item was sent successfully
  bool get isItemSent => _itemSent;

  /// Set the itemSent value
  set isItemSent(bool value) {
    _itemSent = value;
    notifyListeners();
  }

  /// Initialize the FlutterP2pConnection plugin
  Future<void> init() async {
    await _flutterP2pConnectionPlugin.initialize();
    await _flutterP2pConnectionPlugin.register();

    notifyListeners();
  }

  /// Check if the required permissions are granted
  /// If not, request the permissions
  ///
  /// Permissions required:
  /// - Storage
  /// - Location
  /// - Wifi
  /// - NearbyWifiDevices
  Future<void> checkPermissions() async {
    // Check if storage permission is granted
    if (!await FlutterP2pConnection().checkStoragePermission()) {
      // Request storage permission
      await FlutterP2pConnection().askStoragePermission();
    }
    // Check if location is enabled
    if (!await FlutterP2pConnection().checkLocationEnabled()) {
      FlutterP2pConnection().enableLocationServices(); // Enable location
    }
    // Check if wifi is enabled
    if (!await FlutterP2pConnection().checkWifiEnabled()) {
      await FlutterP2pConnection().enableWifiServices(); // Enable wifi
    }
    // Ask all permissions required for group creation and connections (nearbyWifiDevices & location)
    await FlutterP2pConnection().askConnectionPermissions();
  }
}
