import 'package:flutter/material.dart';
import 'package:kupon_bbm_app/domain/models/rekap_satker_model.dart';
import 'package:kupon_bbm_app/domain/repositories/analysis_repository.dart';

class AnalysisProvider extends ChangeNotifier {
  final AnalysisRepository _analysisRepository;

  AnalysisProvider(this._analysisRepository);

  List<RekapSatkerModel> _rekapList = [];
  List<RekapSatkerModel> get rekapList => _rekapList;

  Future<void> fetchRekapSatker() async {
    try {
      final data = await _analysisRepository.getRekapSatker();
      _rekapList = data;
      notifyListeners();
    } catch (e) {
      _rekapList = [];
      notifyListeners();
    }
  }
}
