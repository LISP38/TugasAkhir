class RekapSatkerModel {
  final String namaSatker;
  final double kuotaAwal;
  final double kuotaTerpakai;

  RekapSatkerModel({
    required this.namaSatker,
    required this.kuotaAwal,
    required this.kuotaTerpakai,
  });

  factory RekapSatkerModel.fromMap(Map<String, dynamic> map) {
    return RekapSatkerModel(
      namaSatker: map['nama_satker']?.toString() ?? '',
      kuotaAwal: (map['kuota_awal'] is num)
          ? (map['kuota_awal'] as num).toDouble()
          : double.tryParse(map['kuota_awal']?.toString() ?? '0') ?? 0.0,
      kuotaTerpakai: (map['kuota_terpakai'] is num)
          ? (map['kuota_terpakai'] as num).toDouble()
          : double.tryParse(map['kuota_terpakai']?.toString() ?? '0') ?? 0.0,
    );
  }
}
