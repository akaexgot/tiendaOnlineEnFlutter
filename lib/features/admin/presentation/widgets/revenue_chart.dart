import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../orders/data/models/order_model.dart';
import 'package:intl/intl.dart';

class RevenueChart extends StatelessWidget {
  final List<OrderModel> orders;

  const RevenueChart({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    // 1. Process data: Group by day and sum total
    final data = _processData();
    final maxRevenue = data.fold<double>(0, (max, item) => item.value > max ? item.value : max);
    
    // Sort by date
    data.sort((a, b) => a.date.compareTo(b.date));

    // Taking last 7 days derived from data or filling empty
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ingresos (Últimos ${data.length} días)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
             Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '+12.5%', // Mock growth
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxRevenue == 0 ? 1.0 : maxRevenue / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.textMuted.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < data.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('dd/MM').format(data[index].date),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: maxRevenue == 0 ? 1.0 : maxRevenue / 5,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '€${value.toInt()}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      );
                    },
                    reservedSize: 42,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (data.length - 1).toDouble(),
              minY: 0,
              maxY: maxRevenue * 1.2,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.3),
                        AppColors.primary.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<_ChartData> _processData() {
    // Group orders by date
    final Map<String, double> grouped = {};
    
    // Determine range: last 7 days
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      grouped[key] = 0; // Initialize
    }

    for (final order in orders) {
      if (order.createdAt != null && order.status != 'cancelled') {
        final key = DateFormat('yyyy-MM-dd').format(order.createdAt!);
        if (grouped.containsKey(key)) {
          grouped[key] = (grouped[key] ?? 0) + order.totalPrice;
        }
      }
    }

    return grouped.entries.map((e) {
      return _ChartData(DateTime.parse(e.key), e.value);
    }).toList();
  }
}

class _ChartData {
  final DateTime date;
  final double value;

  _ChartData(this.date, this.value);
}
