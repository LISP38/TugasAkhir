import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kupon_bbm_app/domain/models/rekap_satker_model.dart';

class MinusChartWidget extends StatelessWidget {
  final List<RekapSatkerModel> data;
  final Function(String namaSatker)? onBarTapped;

  const MinusChartWidget({super.key, required this.data, this.onBarTapped});

  @override
  Widget build(BuildContext context) {
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
              minY: 0,
              maxY: 250,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 55,
                    interval: 50,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value % 50 != 0) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 80,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= data.length)
                        return const SizedBox.shrink();
                      final label = data[idx].namaSatker;
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 8,
                        child: Transform.rotate(
                          angle: -0.5,
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: _makeBarGroups(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 50,
                getDrawingHorizontalLine: (value) {
                  if (value % 50 == 0 && value >= 50) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  }
                  return FlLine(color: Colors.transparent);
                },
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  if (event is FlTapUpEvent &&
                      barTouchResponse != null &&
                      barTouchResponse.spot != null &&
                      onBarTapped != null) {
                    final touchedIndex =
                        barTouchResponse.spot!.touchedBarGroupIndex;
                    if (touchedIndex >= 0 && touchedIndex < data.length) {
                      onBarTapped!(data[touchedIndex].namaSatker);
                    }
                  }
                },
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (groupIndex < 0 || groupIndex >= data.length) {
                      return null;
                    }

                    final satkerData = data[groupIndex];
                    final namaSatker = satkerData.namaSatker;
                    final kuotaAwal = satkerData.kuotaAwal.toInt();
                    final kuotaTerpakai = satkerData.kuotaTerpakai.toInt();
                    final kuotaMinus = (kuotaTerpakai - kuotaAwal).toInt();

                    final List<TextSpan> tooltipChildren = [
                      TextSpan(
                        text: 'Total Kuota: $kuotaAwal L\n',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      TextSpan(
                        text: 'Terpakai: $kuotaTerpakai L\n',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      TextSpan(
                        text: '● Minus: $kuotaMinus L',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ];

                    return BarTooltipItem(
                      '$namaSatker\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      children: tooltipChildren,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _makeBarGroups() {
    return List.generate(data.length, (i) {
      final minus = (data[i].kuotaTerpakai - data[i].kuotaAwal).clamp(
        0.0,
        double.infinity,
      );

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: minus,
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(4),
            width: 18,
          ),
        ],
      );
    });
  }
}
