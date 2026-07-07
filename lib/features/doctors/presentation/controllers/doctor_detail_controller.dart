import 'package:flutter/foundation.dart';

import '../../domain/entities/doctor.dart';
import '../../domain/usecases/get_doctor_detail.dart';

class DoctorDetailController extends ChangeNotifier {
  DoctorDetailController({required this._getDoctorDetail});

  final GetDoctorDetail _getDoctorDetail;

  Doctor? _doctor;
  bool _isLoading = false;
  bool _isFavorite = false;
  bool _isAboutExpanded = false;
  String? _errorMessage;

  Doctor? get doctor => _doctor;
  bool get isLoading => _isLoading;
  bool get isFavorite => _isFavorite;
  bool get isAboutExpanded => _isAboutExpanded;
  String? get errorMessage => _errorMessage;

  Future<void> loadDoctor(String doctorId) async {
    _setLoading(true);

    try {
      _doctor = await _getDoctorDetail(doctorId);
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Failed to load doctor profile.';
    } finally {
      _setLoading(false);
    }
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  void toggleAboutExpanded() {
    _isAboutExpanded = !_isAboutExpanded;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
