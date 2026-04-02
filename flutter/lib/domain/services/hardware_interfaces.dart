import '../models/order.dart';

abstract class IPrinterService {
  /// Detects if the current device supports this service natively
  Future<bool> isDeviceSupported();

  /// Prints a standard ticket for an order
  Future<void> printTicket(Order order);

  /// Prints a test receipt to verify configuration
  Future<void> printTest();
}

abstract class IScannerService {
  /// Stream of scanned barcodes (from PDA intent or HID keyboard)
  Stream<String> get barcodeStream;

  /// Manually dispose resources if needed
  void dispose();
}
