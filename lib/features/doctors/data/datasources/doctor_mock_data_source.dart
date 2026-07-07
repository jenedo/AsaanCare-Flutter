import '../models/doctor_model.dart';

class DoctorMockDataSource {
  static const List<DoctorModel> _doctors = [
    DoctorModel(
      id: 'doctor_ali',
      name: 'Dr. Ali Raza',
      qualification: 'MBBS, FCPS (Cardiology)',
      specialty: 'Cardiologist',
      imageAsset: 'assets/images/doctor_ali.png',
      rating: 4.8,
      reviewCount: 1200,
      experienceYears: 10,
      consultationFee: 800,
      patientsCount: 1200,
      about:
          'Expert in treating heart diseases, hypertension, ECG, echocardiography and preventive cardiology care.',
      isVerified: true,
    ),
    DoctorModel(
      id: 'doctor_sara',
      name: 'Dr. Sara Khan',
      qualification: 'MBBS, FCPS (Family Medicine)',
      specialty: 'General Physician',
      imageAsset: 'assets/images/doctor_sara.png',
      rating: 4.8,
      reviewCount: 980,
      experienceYears: 8,
      consultationFee: 800,
      patientsCount: 900,
      about:
          'Experienced general physician for fever, flu, diabetes, blood pressure and family healthcare.',
      isVerified: true,
    ),
    DoctorModel(
      id: 'doctor_maheen',
      name: 'Dr. Maheen Fatima',
      qualification: 'MBBS, FCPS (Gynecology)',
      specialty: 'Gynecologist',
      imageAsset: 'assets/images/doctor_maheen.png',
      rating: 4.9,
      reviewCount: 1100,
      experienceYears: 9,
      consultationFee: 800,
      patientsCount: 1000,
      about:
          'Specialist in women health, pregnancy care, reproductive health and gynecology consultations.',
      isVerified: true,
    ),
  ];

  Future<DoctorModel> getDoctorDetail(String doctorId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return _doctors.firstWhere(
      (doctor) => doctor.id == doctorId,
      orElse: () => _doctors.first,
    );
  }
}
