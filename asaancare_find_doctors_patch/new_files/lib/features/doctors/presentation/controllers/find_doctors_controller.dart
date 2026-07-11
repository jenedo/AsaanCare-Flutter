import 'package:flutter/foundation.dart';

import '../../domain/entities/doctor.dart';
import '../../domain/usecases/get_doctors.dart';

enum DoctorSort { recommended, ratingHigh, feeLow }

class FindDoctorsController extends ChangeNotifier {
  FindDoctorsController({required GetDoctors getDoctors})
    : _getDoctors = getDoctors;

  final GetDoctors _getDoctors;

  List<Doctor> _doctors = const [];
  String _query = '';
  String? _specialty;
  DoctorSort _sort = DoctorSort.recommended;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get specialty => _specialty;
  DoctorSort get sort => _sort;

  List<String> get specialties {
    final values = _doctors.map((doctor) => doctor.specialty).toSet().toList()
      ..sort();
    return values;
  }

  List<Doctor> get visibleDoctors {
    final normalizedQuery = _query.trim().toLowerCase();
    final result = _doctors.where((doctor) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          doctor.name.toLowerCase().contains(normalizedQuery) ||
          doctor.specialty.toLowerCase().contains(normalizedQuery) ||
          doctor.qualification.toLowerCase().contains(normalizedQuery);
      final matchesSpecialty =
          _specialty == null || doctor.specialty == _specialty;
      return matchesQuery && matchesSpecialty;
    }).toList();

    switch (_sort) {
      case DoctorSort.recommended:
        result.sort((a, b) {
          if (a.isVerified != b.isVerified) return a.isVerified ? -1 : 1;
          return b.rating.compareTo(a.rating);
        });
        break;
      case DoctorSort.ratingHigh:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case DoctorSort.feeLow:
        result.sort(
          (a, b) => a.consultationFee.compareTo(b.consultationFee),
        );
        break;
    }

    return List.unmodifiable(result);
  }

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _doctors = await _getDoctors();
    } catch (error, stackTrace) {
      debugPrint('FindDoctorsController.load: $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Doctors could not be loaded. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void setSpecialty(String? value) {
    if (_specialty == value) return;
    _specialty = value;
    notifyListeners();
  }

  void setSort(DoctorSort value) {
    if (_sort == value) return;
    _sort = value;
    notifyListeners();
  }
}
