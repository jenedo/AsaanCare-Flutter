import '../../domain/entities/doctor_profile_state.dart';

class DoctorProfileMockDataSource {
  final Map<String, DoctorProfileState> _profiles =
      <String, DoctorProfileState>{};

  Future<DoctorProfileState> loadProfile({required String doctorId}) async {
    _validate(doctorId);
    return _profiles.putIfAbsent(doctorId, DoctorProfileState.new);
  }

  Future<DoctorProfileState> saveProfile({
    required String doctorId,
    required DoctorProfileState state,
  }) async {
    _validate(doctorId);
    _profiles[doctorId] = state;
    return state;
  }

  void reset() => _profiles.clear();

  void _validate(String doctorId) {
    if (doctorId.trim().isEmpty) {
      throw ArgumentError.value(doctorId, 'doctorId');
    }
  }
}
