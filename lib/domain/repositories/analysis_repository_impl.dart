import 'package:kupon_bbm_app/data/datasources/database_datasource.dart';
import 'package:kupon_bbm_app/domain/models/rekap_satker_model.dart';
import 'package:kupon_bbm_app/domain/models/kendaraan_rekap_model.dart';
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
      WITH kendaraan_minus AS (
        SELECT 
          dk.satker_id,
          COALESCE(SUM(dkup.kuota_awal), 0) as kuota_awal,
          COALESCE(SUM(ft.jumlah_liter), 0) as kuota_terpakai,
          (COALESCE(SUM(ft.jumlah_liter), 0) - COALESCE(SUM(dkup.kuota_awal), 0)) as kuota_minus
        FROM dim_kendaraan dk
        LEFT JOIN dim_kupon dkup ON dk.kendaraan_id = dkup.kendaraan_id AND dkup.is_current = 1
        LEFT JOIN fact_transaksi ft ON dkup.kupon_key = ft.kupon_key AND ft.is_deleted = 0
        GROUP BY dk.satker_id, dk.kendaraan_id
        HAVING kuota_minus > 0
      )
      SELECT 
        ds.nama_satker,
        SUM(km.kuota_awal) as kuota_awal,
        SUM(km.kuota_terpakai) as kuota_terpakai
      FROM dim_satker ds
      INNER JOIN kendaraan_minus km ON ds.satker_id = km.satker_id
      GROUP BY ds.satker_id, ds.nama_satker
      ORDER BY (SUM(km.kuota_terpakai) - SUM(km.kuota_awal)) DESC
    ''');

    return result.map((e) {
      return RekapSatkerModel(
        namaSatker: e['nama_satker'] as String,
        kuotaAwal: (e['kuota_awal'] as num).toDouble(),
        kuotaTerpakai: (e['kuota_terpakai'] as num).toDouble(),
      );
    }).toList();
  }

  /// Get daftar kendaraan dengan total kuota terpakai per satker
  Future<List<KendaraanRekapModel>> getKendaraanBySatker(
    String namaSatker,
  ) async {
    final db = await dbHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT 
        dk.kendaraan_id,
        dk.jenis_ranmor,
        dk.no_pol_kode,
        dk.no_pol_nomor,
        COALESCE(SUM(ft.jumlah_liter), 0) as kuota_terpakai
      FROM dim_kendaraan dk
      INNER JOIN dim_satker ds ON dk.satker_id = ds.satker_id
      LEFT JOIN fact_transaksi ft ON dk.kendaraan_id = ft.kendaraan_id AND ft.is_deleted = 0
      WHERE ds.nama_satker = ?
      GROUP BY dk.kendaraan_id, dk.jenis_ranmor, dk.no_pol_kode, dk.no_pol_nomor
      ORDER BY kuota_terpakai DESC
    ''',
      [namaSatker],
    );

    return result.map((m) => KendaraanRekapModel.fromMap(m)).toList();
  }

  /// Get daftar kendaraan dengan kuota minus per satker
  Future<List<KendaraanRekapModel>> getKendaraanMinusBySatker(
    String namaSatker,
  ) async {
    final db = await dbHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT 
        dk.kendaraan_id,
        dk.jenis_ranmor,
        dk.no_pol_kode,
        dk.no_pol_nomor,
        (COALESCE(SUM(ft.jumlah_liter), 0) - COALESCE(SUM(dkup.kuota_awal), 0)) as kuota_terpakai
      FROM dim_kendaraan dk
      INNER JOIN dim_satker ds ON dk.satker_id = ds.satker_id
      LEFT JOIN dim_kupon dkup ON dk.kendaraan_id = dkup.kendaraan_id AND dkup.is_current = 1
      LEFT JOIN fact_transaksi ft ON dkup.kupon_key = ft.kupon_key AND ft.is_deleted = 0
      WHERE ds.nama_satker = ?
      GROUP BY dk.kendaraan_id, dk.jenis_ranmor, dk.no_pol_kode, dk.no_pol_nomor
      HAVING kuota_terpakai > 0
      ORDER BY kuota_terpakai DESC
    ''',
      [namaSatker],
    );

    return result.map((m) => KendaraanRekapModel.fromMap(m)).toList();
  }
}
