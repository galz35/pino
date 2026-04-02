import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/hardware_interfaces.dart';
import '../../infrastructure/services/sunmi_printer_service.dart';
import '../../infrastructure/services/generic_printer_service.dart';

final printerServiceProvider = FutureProvider<IPrinterService>((ref) async {
  // 1. Try Sunmi First
  final sunmiService = SunmiPrinterService();
  if (await sunmiService.isDeviceSupported()) {
    return sunmiService;
  }

  // 2. Fallback to Generic
  return GenericPrinterService();
});
