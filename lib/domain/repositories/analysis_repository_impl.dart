import 'package:kupon_bbm_app/data/datasources/database_datasource.dart';
import 'package:kupon_bbm_app/domain/models/rekap_satker_model.dart';
import 'package:kupon_bbm_app/domain/repositories/analysis_repository.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  final DatabaseDatasource dbHelper;

  AnalysisRepositoryImpl(this.dbHelper);

  @override
  Future<List<RekapSatkerModel>> getRekapSatker() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        ds.nama_satker AS nama_satker,
        COALESCE(SUM(dk.kuota_awal), 0) AS kuota_awal,
        COALESCE((
          SELECT SUM(jumlah_liter) FROM fact_transaksi ft
          WHERE ft.satker_id = ds.satker_id AND ft.is_deleted = 0
        ), 0) AS kuota_terpakai
      FROM dim_satker ds
      LEFT JOIN dim_kupon dk ON ds.satker_id = dk.satker_id AND dk.is_current = 1
      GROUP BY ds.satker_id, ds.nama_satker
      HAVING COALESCE(SUM(dk.kuota_awal), 0) > 0 OR COALESCE((
        SELECT SUM(jumlah_liter) FROM fact_transaksi ft
        WHERE ft.satker_id = ds.satker_id AND ft.is_deleted = 0
      ), 0) > 0
    ''');

    return result.map((m) => RekapSatkerModel.fromMap(m)).toList();
  }

  Future<List<RekapSatkerModel>> getKuponMinusPerSatker() async {
    final db = await dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        ds.nama_satker,
        SUM(dk.kuota_sisa) as total_sisa
      FROM dim_kupon dk
      JOIN dim_satker ds ON dk.satker_id = ds.satker_id
      WHERE dk.is_deleted = 0
      GROUP BY ds.satker_id, ds.nama_satker
      HAVING total_sisa < 0
    ''');

    return result.map((e) {
      return RekapSatkerModel(
        namaSatker: e['nama_satker'] as String,
        kuotaAwal: 0,
        kuotaTerpakai: (e['total_sisa'] as num).toDouble().abs(),
      );
    }).toList();
  }


}
