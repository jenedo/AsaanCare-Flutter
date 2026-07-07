import '../entities/doctor.dart';

abstract class DoctorRepository {
  Future<Doctor> getDoctorDetail(String doctorId);
}
