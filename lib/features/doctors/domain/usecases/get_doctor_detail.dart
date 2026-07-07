import '../entities/doctor.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorDetail {
  const GetDoctorDetail(this._repository);

  final DoctorRepository _repository;

  Future<Doctor> call(String doctorId) {
    return _repository.getDoctorDetail(doctorId);
  }
}
