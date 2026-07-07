import '../../domain/entities/doctor.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../datasources/doctor_mock_data_source.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  const DoctorRepositoryImpl({required this._mockDataSource});

  final DoctorMockDataSource _mockDataSource;

  @override
  Future<Doctor> getDoctorDetail(String doctorId) {
    return _mockDataSource.getDoctorDetail(doctorId);
  }
}
