import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kupon_bbm_app/domain/models/rekap_satker_model.dart';

class AnalysisChartWidget extends StatelessWidget {
  final List<RekapSatkerModel> data;

  const AnalysisChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.fold<double>(0.0, (prev, e) => (e.kuotaAwal > prev) ? e.kuotaAwal : prev);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
          aspectRatio: 1.7,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxValue * 1.15).clamp(1.0, double.infinity),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                      final label = data[idx].namaSatker;
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: SizedBox(
                          width: 80,
                          child: Text(
                            label,
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: _makeBarGroups(),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _makeBarGroups() {
    return List.generate(data.length, (i) {
      final used = data[i].kuotaTerpakai;
      final sisa = (data[i].kuotaAwal - used).clamp(0.0, double.infinity);

      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: used + sisa,
          rodStackItems: [
            BarChartRodStackItem(0, used, Colors.blueAccent),
            BarChartRodStackItem(used, used + sisa, Colors.lightBlueAccent),
          ],
          borderRadius: BorderRadius.circular(4),
          width: 18,
        )
      ]);
    });
  }
}
