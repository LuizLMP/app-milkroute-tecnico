import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider(
    this._connectivity,
  );

  final Connectivity _connectivity;
  late StreamSubscription _connectivitySub;
  ConnectivityResult _connectivityResult = ConnectivityResult.other;
  ConnectivityResult get state => _connectivityResult;

  Future<void> init() async {
    await initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();

    super.dispose();
  }

  Future<void> refreshConnectivity() {
    return _connectivity.checkConnectivity().then((state) {
      _connectivityResult = state.first;
      notifyListeners();
    });
  }

  bool get appIsOnline => _connectivityResult != ConnectivityResult.none;

  Future<void> initConnectivity() async {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((result) {
      _connectivityResult = result.first;

      notifyListeners();
    });
    return refreshConnectivity();
  }
}
