import 'package:flutter/material.dart';
import 'package:kupon_bbm_app/presentation/widgets/analysis_chart_widget.dart';
import 'package:kupon_bbm_app/domain/models/rekap_satker_model.dart';
import 'package:kupon_bbm_app/domain/repositories/analysis_repository_impl.dart';
import 'package:kupon_bbm_app/data/datasources/database_datasource.dart';

class AnalysisDataPage extends StatelessWidget {
  final AnalysisRepositoryImpl? repository;

  const AnalysisDataPage({super.key, this.repository});

  AnalysisRepositoryImpl get _repo => repository ?? AnalysisRepositoryImpl(DatabaseDatasource());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Analisis Data Kupon',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // Card 1: Bar Chart
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Rekapitulasi Penggunaan BBM per Satuan Kerja', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),

                  FutureBuilder<List<RekapSatkerModel>>(
                    future: _repo.getRekapSatker(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                      }

                      if (snapshot.hasError) {
                        return SizedBox(height: 120, child: Center(child: Text('Error: ${snapshot.error}')));
                      }

                      final data = snapshot.data ?? <RekapSatkerModel>[];
                      return AnalysisChartWidget(data: data);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Card 2: Placeholder
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 180,
                child: Center(child: Text('Placeholder for chart 2', style: Theme.of(context).textTheme.bodyMedium)),
              ),
            ),
          ),

          // Card(
          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //   color: Colors.white,
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.stretch,
          //       children: [
          //         Text(
          //           'Kupon Minus per Satuan Kerja',
          //           style: Theme.of(context).textTheme.titleMedium,
          //         ),
          //         const SizedBox(height: 12),

          //         FutureBuilder<List<RekapSatkerModel>>(
          //           future: _repo.getKuponMinusPerSatker(),
          //           builder: (context, snapshot) {
          //             if (snapshot.connectionState == ConnectionState.waiting) {
          //               return const SizedBox(
          //                 height: 200,
          //                 child: Center(child: CircularProgressIndicator()),
          //               );
          //             }

          //             if (snapshot.hasError) {
          //               return SizedBox(
          //                 height: 120,
          //                 child: Center(child: Text('Error: ${snapshot.error}')),
          //               );
          //             }

          //             final data = snapshot.data ?? [];

          //             if (data.isEmpty) {
          //               return const SizedBox(
          //                 height: 120,
          //                 child: Center(child: Text('Tidak ada satker minus')),
          //               );
          //             }

          //             return AnalysisChartWidget(data: data);
          //           },
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
