import 'package:flutter/foundation.dart';

import '../../domain/entities/doctor_profile_state.dart';
import '../../domain/repositories/doctor_profile_repository.dart';

class DoctorProfileController extends ChangeNotifier {
  DoctorProfileController({required this._repository});

  final DoctorProfileRepository _repository;

  DoctorProfileState _state = const DoctorProfileState();
  String? _doctorId;
  bool _isLoaded = false;

  DoctorProfileState get state => _state;

  Future<void> load({required String doctorId}) async {
    final normalizedId = doctorId.trim();
    if (normalizedId.isEmpty) return;
    if (_isLoaded && _doctorId == normalizedId) return;
    _doctorId = normalizedId;
    _state = await _repository.loadProfile(doctorId: normalizedId);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setPage(int page) => _save(_state.copyWith(page: page));

  Future<void> saveIdentity({required String name, required String specialty}) {
    return _save(
      _state.copyWith(
        name: name.trim().isEmpty ? _state.name : name.trim(),
        specialty: specialty.trim().isEmpty
            ? _state.specialty
            : specialty.trim(),
      ),
    );
  }

  Future<void> saveProfessional({
    required String specialty,
    required String qualification,
  }) {
    return _save(
      _state.copyWith(
        specialty: specialty.trim().isEmpty
            ? _state.specialty
            : specialty.trim(),
        qualification: qualification.trim().isEmpty
            ? _state.qualification
            : qualification.trim(),
      ),
    );
  }

  Future<void> saveClinic({required String clinic, required String address}) {
    return _save(
      _state.copyWith(
        clinic: clinic.trim().isEmpty ? _state.clinic : clinic.trim(),
        address: address.trim().isEmpty ? _state.address : address.trim(),
      ),
    );
  }

  Future<void> saveFee(int fee) => _save(_state.copyWith(fee: fee));
  Future<void> saveDays(List<String> days) =>
      _save(_state.copyWith(days: days.isEmpty ? const ['Mon'] : days));
  Future<void> savePreferences({
    required bool autoApprove,
    required bool reschedule,
  }) =>
      _save(_state.copyWith(autoApprove: autoApprove, reschedule: reschedule));
  Future<void> saveVideoSettings({
    required bool video,
    required bool recordingConsent,
  }) =>
      _save(_state.copyWith(video: video, recordingConsent: recordingConsent));
  Future<void> savePhone(String phone) => _save(
    _state.copyWith(phone: phone.trim().isEmpty ? _state.phone : phone.trim()),
  );
  Future<void> saveEmail(String email) => _save(
    _state.copyWith(email: email.trim().isEmpty ? _state.email : email.trim()),
  );
  Future<void> saveBank(String bank) => _save(
    _state.copyWith(bank: bank.trim().isEmpty ? _state.bank : bank.trim()),
  );
  Future<void> saveLanguage(String value) =>
      _save(_state.copyWith(language: value));
  Future<void> saveAppearance(String value) =>
      _save(_state.copyWith(appearance: value));
  Future<void> savePrivacy({required bool twoFactor, required bool isPublic}) =>
      _save(_state.copyWith(twoFactor: twoFactor, public: isPublic));
  Future<void> saveNotifications({required bool push, required bool sms}) =>
      _save(_state.copyWith(push: push, sms: sms));

  Future<void> _save(DoctorProfileState nextState) async {
    final doctorId = _doctorId;
    if (doctorId == null) {
      _state = nextState;
      notifyListeners();
      return;
    }
    _state = await _repository.saveProfile(
      doctorId: doctorId,
      state: nextState,
    );
    notifyListeners();
  }
}
