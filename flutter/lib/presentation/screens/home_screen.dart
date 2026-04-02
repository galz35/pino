import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('Building HomeScreen'); // Debug log

    return Scaffold(
      appBar: AppBar(title: const Text('Bodega Los Pinos Mobile')),
      body: Center(
        // Center content to ensure it's visible
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.store,
              size: 64,
              color: Colors.blue,
            ), // Visual indicator
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to Order Create
                context.go('/create-order');
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Nueva Preventa'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                // Test Printer
                final printerAsync = ref.read(printerServiceProvider);
                printerAsync.whenData((printer) => printer.printTest());
              },
              icon: const Icon(Icons.print),
              label: const Text('Test Impresora'),
            ),
            const SizedBox(height: 10),
            // Status Indicator for Scanner
            Consumer(
              builder: (context, ref, _) {
                final scanner = ref.watch(scannerServiceProvider);
                return StreamBuilder<String>(
                  stream: scanner.barcodeStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        'Último Scan: ${snapshot.data}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    }
                    return const Text('Esperando Escáner...');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
