import '../entities/doctor.dart';

abstract class DoctorRepository {
  Future<List<Doctor>> getDoctors();

  Future<Doctor> getDoctorDetail(String doctorId);
}

