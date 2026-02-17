import '../models/rekap_satker_model.dart';

abstract class AnalysisRepository {
  Future<List<RekapSatkerModel>> getRekapSatker();
}
