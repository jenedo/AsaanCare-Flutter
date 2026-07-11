import '../entities/doctor.dart';
import '../repositories/doctor_repository.dart';

class GetDoctors {
  const GetDoctors(this._repository);

  final DoctorRepository _repository;

  Future<List<Doctor>> call() => _repository.getDoctors();
}
