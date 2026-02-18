class KendaraanRekapModel {
  final int kendaraanId;
  final String jenisRanmor;
  final String noPolKode;
  final String noPolNomor;
  final double kuotaTerpakai;

  KendaraanRekapModel({
    required this.kendaraanId,
    required this.jenisRanmor,
    required this.noPolKode,
    required this.noPolNomor,
    required this.kuotaTerpakai,
  });

  factory KendaraanRekapModel.fromMap(Map<String, dynamic> map) {
    return KendaraanRekapModel(
      kendaraanId: map['kendaraan_id'] as int,
      jenisRanmor: map['jenis_ranmor']?.toString() ?? '',
      noPolKode: map['no_pol_kode']?.toString() ?? '',
      noPolNomor: map['no_pol_nomor']?.toString() ?? '',
      kuotaTerpakai: (map['kuota_terpakai'] is num) 
          ? (map['kuota_terpakai'] as num).toDouble() 
          : double.tryParse(map['kuota_terpakai']?.toString() ?? '0') ?? 0.0,
    );
  }

  String get nomorPolisi => '$noPolKode-$noPolNomor';
}
