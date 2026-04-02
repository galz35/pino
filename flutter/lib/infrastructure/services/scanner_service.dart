import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../domain/services/hardware_interfaces.dart';

class ScannerService implements IScannerService {
  final StreamController<String> _barcodeController =
      StreamController<String>.broadcast();
  StreamSubscription? _broadcastSubscription;

  ScannerService() {
    _initBroadcastReceiver();
  }

  static const _eventChannel = EventChannel(
    'com.bodegalospinos.los_pinos_mobile/scanner_events',
  );

  void _initBroadcastReceiver() {
    _broadcastSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is! Map) return;
        final Map<Object?, Object?> data = event;

        // Common keys used by scanner intents
        final possibleKeys = [
          'scanner_data',
          'data',
          'barcode_string',
          'scanned_data',
          'barcode',
          'com.symbol.datawedge.data_string', // Zebra Modern Key
          'SCAN_BARCODE1', // Zebra Legacy
          'EXTRA_BARCODE_DATA', // some others
        ];

        String? code;
        for (var key in possibleKeys) {
          if (data.containsKey(key)) {
            code = data[key]?.toString();
            if (code != null && code.isNotEmpty) break;
          }
        }

        if (code != null && code.isNotEmpty) {
          _barcodeController.add(code);
        }
      },
      onError: (Object error) {
        debugPrint('Scanner EventChannel error: $error');
      },
    );
  }

  /// Can be called from UI RawKeyboardListener to inject non-intent scans
  void injectScan(String code) {
    _barcodeController.add(code);
  }

  @override
  Stream<String> get barcodeStream => _barcodeController.stream;

  @override
  void dispose() {
    _broadcastSubscription?.cancel();
    _barcodeController.close();
  }
}
