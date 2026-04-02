import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../../domain/models/order.dart';
import '../../domain/services/hardware_interfaces.dart';

class GenericPrinterService implements IPrinterService {
  @override
  Future<bool> isDeviceSupported() async {
    // This is the fallback service, so it supports "any" android device
    // capable of Bluetooth.
    // In a real logic, we might check if Bluetooth is on.
    return true;
  }

  Future<List<int>> _generateTicketBytes(Order order) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.reset();
    bytes += generator.text(
      'BODEGA LOS PINOS',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      'Ticket de Venta',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(1);
    bytes += generator.text('Orden: ${order.id.substring(0, 8)}');
    bytes += generator.text('Cliente: ${order.clientId}');
    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(text: 'Cant', width: 2),
      PosColumn(text: 'Desc', width: 7),
      PosColumn(
        text: 'Total',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr();

    double total = 0;
    for (var item in order.items) {
      bytes += generator.row([
        PosColumn(text: '${item.quantity}', width: 2),
        PosColumn(text: item.description, width: 7),
        PosColumn(
          text: item.total.toStringAsFixed(2),
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      total += item.total;
    }

    bytes += generator.hr();

    bytes += generator.text(
      'TOTAL: C\$ ${total.toStringAsFixed(2)}',
      styles: const PosStyles(
        align: PosAlign.right,
        bold: true,
        height: PosTextSize.size2,
      ),
    );

    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  @override
  Future<void> printTicket(Order order) async {
    // 1. Get List of Paired Devices (User must select one in settings ideally,
    // but here we pick provided mac or first found for simplicity in this HAL demo)
    // In a real app, you'd save the Mac Address in Preferences.
    /*
    final List<BluetoothInfo> list = await PrintBluetoothThermal.pairedBluetoothPrinters;
    if (list.isEmpty) return; // No printer
    final String mac = list.first.macAdress; 
    */

    // NOTE: This requires a connected state.
    // For this implementation, we assume the UI handles connection
    // or we try to connect to a saved MAC.
    // Since we don't have a UI for selection yet, this method stubs the
    // connectivity check.

    bool connected = await PrintBluetoothThermal.connectionStatus;
    if (!connected) {
      // logic to connect to saved printer would go here
      return;
    }

    final bytes = await _generateTicketBytes(order);
    await PrintBluetoothThermal.writeBytes(bytes);
  }

  @override
  Future<void> printTest() async {
    bool connected = await PrintBluetoothThermal.connectionStatus;
    if (connected) {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];
      bytes += generator.text('Test Generic Printer');
      bytes += generator.feed(2);
      await PrintBluetoothThermal.writeBytes(bytes);
    }
  }
}
