import '../entities/doctor_profile_state.dart';

abstract class DoctorProfileRepository {
  Future<DoctorProfileState> loadProfile({required String doctorId});
  Future<DoctorProfileState> saveProfile({
    required String doctorId,
    required DoctorProfileState state,
  });
  void reset();
}
