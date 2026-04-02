import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

import '../../domain/models/order.dart';
import '../../domain/services/hardware_interfaces.dart';

class SunmiPrinterService implements IPrinterService {
  bool _isConnected = false;

  @override
  Future<bool> isDeviceSupported() async {
    try {
      // ignore: deprecated_member_use
      final bool? result = await SunmiPrinter.bindingPrinter();
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _ensureConnection() async {
    if (!_isConnected) {
      // ignore: deprecated_member_use
      final result = await SunmiPrinter.bindingPrinter();
      _isConnected = result ?? false;
    }
  }

  @override
  Future<void> printTicket(Order order) async {
    await _ensureConnection();
    if (!_isConnected) return;

    // ignore: deprecated_member_use
    await SunmiPrinter.startTransactionPrint(true);

    // Header
    await SunmiPrinter.printText(
      'BODEGA LOS PINOS',
      style: SunmiTextStyle(
        fontSize: 30,
        bold: true,
        align: SunmiPrintAlign.CENTER,
      ),
    );
    await SunmiPrinter.printText(
      'Ticket de Venta\n',
      style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
    );

    await SunmiPrinter.printText(
      'Orden: ${order.id.substring(0, 8)}',
      style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
    );
    await SunmiPrinter.printText(
      'Fecha: ${order.createdAt.toString().split('.')[0]}',
      style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
    );
    await SunmiPrinter.printText(
      'Cliente: ${order.clientId}',
      style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
    );
    await SunmiPrinter.lineWrap(1);

    // Separator
    await SunmiPrinter.printText('--------------------------------');

    // Items
    await SunmiPrinter.printRow(
      cols: [
        SunmiColumn(text: 'Cant', width: 4),
        SunmiColumn(text: 'Desc', width: 16),
        SunmiColumn(text: 'Total', width: 10),
      ],
    );

    await SunmiPrinter.printText('--------------------------------');

    double total = 0;
    for (var item in order.items) {
      await SunmiPrinter.printRow(
        cols: [
          SunmiColumn(text: '${item.quantity}', width: 4),
          SunmiColumn(text: item.description, width: 16),
          SunmiColumn(text: item.total.toStringAsFixed(2), width: 10),
        ],
      );
      total += item.total;
    }

    await SunmiPrinter.printText('--------------------------------');

    // Totals
    await SunmiPrinter.printText(
      'TOTAL: C\$ ${total.toStringAsFixed(2)}',
      style: SunmiTextStyle(
        fontSize: 24,
        bold: true,
        align: SunmiPrintAlign.RIGHT,
      ),
    );

    await SunmiPrinter.lineWrap(3);
    // await SunmiPrinter.submitTransactionPrint();
    // ignore: deprecated_member_use
    await SunmiPrinter.exitTransactionPrint(true);
  }

  @override
  Future<void> printTest() async {
    await _ensureConnection();
    if (!_isConnected) return;

    // ignore: deprecated_member_use
    await SunmiPrinter.startTransactionPrint(true);
    await SunmiPrinter.printText(
      'TEST IMPRESION SUNMI',
      style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
    );
    await SunmiPrinter.printText('--------------------------------');
    await SunmiPrinter.lineWrap(3);
    // await SunmiPrinter.submitTransactionPrint();
    // ignore: deprecated_member_use
    await SunmiPrinter.exitTransactionPrint(true);
  }
}
