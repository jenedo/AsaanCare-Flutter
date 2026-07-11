import 'package:asaancare/features/doctors/domain/entities/doctor.dart';
import 'package:asaancare/features/doctors/domain/repositories/doctor_repository.dart';
import 'package:asaancare/features/doctors/domain/usecases/get_doctors.dart';
import 'package:asaancare/features/doctors/presentation/controllers/find_doctors_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FindDoctorsController controller;

  setUp(() {
    controller = FindDoctorsController(
      getDoctors: GetDoctors(_FakeDoctorRepository()),
    );
  });

  tearDown(() => controller.dispose());

  test('loads, searches, filters and sorts doctors', () async {
    await controller.load();

    expect(controller.visibleDoctors, hasLength(3));

    controller.setQuery('heart');
    expect(controller.visibleDoctors.single.id, 'ali');

    controller.setQuery('');
    controller.setSpecialty('Dermatologist');
    expect(controller.visibleDoctors.single.id, 'sara');

    controller.setSpecialty(null);
    controller.setSort(DoctorSort.feeLow);
    expect(controller.visibleDoctors.first.consultationFee, 500);
  });
}

class _FakeDoctorRepository implements DoctorRepository {
  final _doctors = const [
    Doctor(
      id: 'ali',
      name: 'Dr. Ali',
      qualification: 'Heart specialist',
      specialty: 'Cardiologist',
      imageAsset: '',
      rating: 4.9,
      reviewCount: 10,
      experienceYears: 8,
      consultationFee: 900,
      patientsCount: 50,
      about: '',
      isVerified: true,
    ),
    Doctor(
      id: 'sara',
      name: 'Dr. Sara',
      qualification: 'Skin specialist',
      specialty: 'Dermatologist',
      imageAsset: '',
      rating: 4.7,
      reviewCount: 10,
      experienceYears: 6,
      consultationFee: 700,
      patientsCount: 50,
      about: '',
      isVerified: true,
    ),
    Doctor(
      id: 'amna',
      name: 'Dr. Amna',
      qualification: 'Family medicine',
      specialty: 'General Physician',
      imageAsset: '',
      rating: 4.6,
      reviewCount: 10,
      experienceYears: 5,
      consultationFee: 500,
      patientsCount: 50,
      about: '',
      isVerified: true,
    ),
  ];

  @override
  Future<List<Doctor>> getDoctors() async => _doctors;

  @override
  Future<Doctor> getDoctorDetail(String doctorId) async =>
      _doctors.firstWhere((doctor) => doctor.id == doctorId);
}
