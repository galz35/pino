import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../data/providers/providers.dart';
import '../../../../domain/models/daily_closing.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/closing_provider.dart';

class DayClosingScreen extends ConsumerStatefulWidget {
  const DayClosingScreen({super.key});

  @override
  ConsumerState<DayClosingScreen> createState() => _DayClosingScreenState();
}

class _DayClosingScreenState extends ConsumerState<DayClosingScreen> {
  final Map<String, int> _cordobas = {
    '1000': 0,
    '500': 0,
    '200': 0,
    '100': 0,
    '50': 0,
    '20': 0,
    '10': 0,
    '5': 0,
    '1': 0,
  };
  final Map<String, int> _dollars = {
    '100': 0,
    '50': 0,
    '20': 0,
    '10': 0,
    '5': 0,
    '1': 0,
  };

  double _calculateTotal(Map<String, int> counts) {
    double total = 0;
    counts.forEach((denom, quantity) {
      total += double.parse(denom) * quantity;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final totalC = _calculateTotal(_cordobas);
    final totalD = _calculateTotal(_dollars);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Liquidación Final'),
        backgroundColor: AppColors.surface,
      ),
      body: settingsAsync.when(
        data: (settings) {
          final systemTotalAsync = ref.watch(todaySystemTotalProvider);
          final totalPhysical = totalC + (totalD * settings.exchangeRate);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(
                  totalC,
                  totalD,
                  totalPhysical,
                  settings.exchangeRate,
                  systemTotalAsync,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Efectivo en Córdobas (C\$)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDenominationList(_cordobas, 'C\$'),
                const SizedBox(height: 24),
                const Text(
                  'Efectivo en Dólares (\$)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDenominationList(_dollars, '\$'),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showConfirmDialog(totalPhysical),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'GUARDAR LIQUIDACIÓN',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSummaryCard(
    double tc,
    double td,
    double total,
    double xr,
    double systemTotal,
  ) {
    final difference = total - systemTotal;
    final isShortage = difference < -1; // Allow some small rounding diff
    final isSurplus = difference > 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isShortage
              ? Colors.red.withValues(alpha: 0.5)
              : isSurplus
              ? Colors.green.withValues(alpha: 0.5)
              : AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL FÍSICO CONTADO',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'C\$ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'SISTEMA',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'C\$ ${systemTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32, color: AppColors.surfaceVariant),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DIFERENCIA',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                'C\$ ${difference.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isShortage
                      ? Colors.red
                      : isSurplus
                      ? Colors.green
                      : Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: AppColors.surfaceVariant),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat('Córdobas', 'C\$ ${tc.toStringAsFixed(0)}'),
              _buildMiniStat('Dólares', '\$ ${td.toStringAsFixed(0)}'),
              _buildMiniStat('Tasa', 'x${xr.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDenominationList(Map<String, int> counts, String symbol) {
    final denoms = counts.keys.toList()
      ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: denoms.length,
      itemBuilder: (context, index) {
        final d = denoms[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                '$symbol$d',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildCounter(d, counts),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCounter(String denom, Map<String, int> counts) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (counts[denom]! > 0) {
              setState(() => counts[denom] = counts[denom]! - 1);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
            child: const Icon(Icons.remove, size: 14, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${counts[denom]}',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() => counts[denom] = counts[denom]! + 1),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
            child: const Icon(Icons.add, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog(double total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Confirmar Liquidación',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Está seguro de guardar la liquidación por un total de C\$ ${total.toStringAsFixed(2)}?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Get current user from provider
                final user = ref.read(currentUserProvider);
                if (user == null) {
                  throw Exception('Usuario no autenticado');
                }

                // Get current exchange rate
                final settingsAsync = ref.read(settingsProvider);
                final settings = settingsAsync.value;
                if (settings == null) {
                  throw Exception('No se pudo obtener la configuración');
                }

                // Calculate totals
                final totalC = _calculateTotal(_cordobas);
                final totalD = _calculateTotal(_dollars);
                final totalPhysical = totalC + (totalD * settings.exchangeRate);

                // Get system calculated total from provider
                final totalSystemCalculated = ref.read(
                  todaySystemTotalProvider,
                );
                final difference = totalPhysical - totalSystemCalculated;

                // Create DailyClosing object
                final dailyClosing = DailyClosing(
                  id: '', // Backend will generate or we can use empty
                  driverId: user.uid,
                  createdAt: DateTime.now(),
                  exchangeRateSnapshot: settings.exchangeRate,
                  cashCountCordobas: _cordobas,
                  cashCountDollars: _dollars,
                  totalSystemCalculated: totalSystemCalculated,
                  totalPhysicalCounted: totalPhysical,
                  difference: difference,
                );

                // Save via Repository
                await ref
                    .read(ordersRepositoryProvider)
                    .recordDailyClosing(dailyClosing);

                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Liquidación guardada correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al guardar: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );
  }
}
