import '../entities/doctor.dart';

abstract class DoctorRepository {
  Future<List<Doctor>> getDoctors({String? specialty, String? city});

  Future<Doctor> getDoctorDetail(String doctorId);
}
