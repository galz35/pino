import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Watches network connectivity and exposes a reactive stream.
/// Used by the SyncEngine to know when to flush the offline queue.
class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService._();
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChanged => _controller.stream;

  StreamSubscription? _sub;

  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = _isConnected(results);
    _controller.add(_isOnline);

    _sub = _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = _isConnected(results);
      if (wasOnline != _isOnline) {
        debugPrint('[Connectivity] ${_isOnline ? "ONLINE ✓" : "OFFLINE ✗"}');
        _controller.add(_isOnline);
      }
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet,
    );
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
