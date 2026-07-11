import '../models/doctor_model.dart';

class DoctorMockDataSource {
  static final List<DoctorModel> _doctors = List.unmodifiable(
    List.generate(_seeds.length, (index) {
      final seed = _seeds[index];
      return DoctorModel(
        id: seed.id,
        name: seed.name,
        qualification: seed.qualification,
        specialty: seed.specialty,
        imageAsset: seed.imageAsset,
        rating: seed.rating,
        reviewCount: 320 + (index * 47),
        experienceYears: 4 + (index % 13),
        consultationFee: seed.fee,
        patientsCount: 500 + (index * 83),
        about:
            '${seed.name} is a verified ${seed.specialty.toLowerCase()} providing patient-focused consultations, diagnosis and follow-up care.',
        isVerified: index != 19,
      );
    }),
  );

  Future<List<DoctorModel>> getDoctors() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _doctors;
  }

  Future<DoctorModel> getDoctorDetail(String doctorId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return _doctors.firstWhere(
      (doctor) => doctor.id == doctorId,
      orElse: () => _doctors.first,
    );
  }
}

class _DoctorSeed {
  const _DoctorSeed(
    this.id,
    this.name,
    this.qualification,
    this.specialty,
    this.imageAsset,
    this.rating,
    this.fee,
  );

  final String id;
  final String name;
  final String qualification;
  final String specialty;
  final String imageAsset;
  final double rating;
  final int fee;
}

const _seeds = <_DoctorSeed>[
  _DoctorSeed('doctor_ali', 'Dr. Ali Raza', 'MBBS, FCPS Cardiology', 'Cardiologist', 'assets/images/doctor_ali.png', 4.9, 1000),
  _DoctorSeed('doctor_sara', 'Dr. Sara Khan', 'MBBS, FCPS Family Medicine', 'General Physician', 'assets/images/doctor_sara.png', 4.8, 800),
  _DoctorSeed('doctor_maheen', 'Dr. Maheen Fatima', 'MBBS, FCPS Gynecology', 'Gynecologist', 'assets/images/doctor_maheen.png', 4.9, 900),
  _DoctorSeed('doctor_hamza', 'Dr. Hamza Ahmed', 'MBBS, FCPS Pediatrics', 'Pediatrician', 'assets/images/doctor_ali.png', 4.7, 750),
  _DoctorSeed('doctor_ayesha', 'Dr. Ayesha Noor', 'MBBS, FCPS Dermatology', 'Dermatologist', 'assets/images/doctor_sara.png', 4.9, 1200),
  _DoctorSeed('doctor_usman', 'Dr. Usman Tariq', 'BDS, FCPS Dentistry', 'Dentist', 'assets/images/doctor_ali.png', 4.6, 700),
  _DoctorSeed('doctor_hira', 'Dr. Hira Aslam', 'MBBS, FCPS Psychiatry', 'Psychiatrist', 'assets/images/doctor_maheen.png', 4.8, 1100),
  _DoctorSeed('doctor_bilal', 'Dr. Bilal Hussain', 'MBBS, MS Orthopedics', 'Orthopedic Surgeon', 'assets/images/doctor_ali.png', 4.7, 1300),
  _DoctorSeed('doctor_zainab', 'Dr. Zainab Malik', 'MBBS, FCPS ENT', 'ENT Specialist', 'assets/images/doctor_sara.png', 4.8, 850),
  _DoctorSeed('doctor_ahmed', 'Dr. Ahmed Farooq', 'MBBS, FCPS Neurology', 'Neurologist', 'assets/images/doctor_ali.png', 4.9, 1500),
  _DoctorSeed('doctor_maryam', 'Dr. Maryam Iqbal', 'MBBS, FCPS Ophthalmology', 'Eye Specialist', 'assets/images/doctor_maheen.png', 4.6, 900),
  _DoctorSeed('doctor_omar', 'Dr. Omar Siddiqui', 'MBBS, FCPS Pulmonology', 'Pulmonologist', 'assets/images/doctor_ali.png', 4.7, 1100),
  _DoctorSeed('doctor_fatima', 'Dr. Fatima Zahra', 'MBBS, FCPS Endocrinology', 'Endocrinologist', 'assets/images/doctor_sara.png', 4.8, 1250),
  _DoctorSeed('doctor_saif', 'Dr. Saif Rehman', 'MBBS, FCPS Urology', 'Urologist', 'assets/images/doctor_ali.png', 4.7, 1400),
  _DoctorSeed('doctor_nimra', 'Dr. Nimra Shah', 'MBBS, FCPS Gastroenterology', 'Gastroenterologist', 'assets/images/doctor_maheen.png', 4.8, 1350),
  _DoctorSeed('doctor_junaid', 'Dr. Junaid Akram', 'MBBS, FCPS Nephrology', 'Nephrologist', 'assets/images/doctor_ali.png', 4.6, 1300),
  _DoctorSeed('doctor_rabia', 'Dr. Rabia Saleem', 'MBBS, FCPS Oncology', 'Oncologist', 'assets/images/doctor_sara.png', 4.9, 1600),
  _DoctorSeed('doctor_fahad', 'Dr. Fahad Qureshi', 'MBBS, FCPS General Surgery', 'General Surgeon', 'assets/images/doctor_ali.png', 4.7, 1500),
  _DoctorSeed('doctor_sana', 'Dr. Sana Mir', 'DPT, MS Physiotherapy', 'Physiotherapist', 'assets/images/doctor_maheen.png', 4.8, 650),
  _DoctorSeed('doctor_adnan', 'Dr. Adnan Bashir', 'MBBS, Diploma Diabetology', 'Diabetes Specialist', 'assets/images/doctor_ali.png', 4.5, 800),
  _DoctorSeed('doctor_mahnoor', 'Dr. Mahnoor Khan', 'MBBS, FCPS Rheumatology', 'Rheumatologist', 'assets/images/doctor_sara.png', 4.8, 1200),
  _DoctorSeed('doctor_talha', 'Dr. Talha Mahmood', 'MBBS, FCPS Internal Medicine', 'Internal Medicine', 'assets/images/doctor_ali.png', 4.7, 1000),
  _DoctorSeed('doctor_eman', 'Dr. Eman Khalid', 'MBBS, MCPS Family Medicine', 'General Physician', 'assets/images/doctor_maheen.png', 4.6, 600),
  _DoctorSeed('doctor_hassan', 'Dr. Hassan Rauf', 'MBBS, FCPS Anesthesiology', 'Pain Specialist', 'assets/images/doctor_ali.png', 4.7, 950),
  _DoctorSeed('doctor_komal', 'Dr. Komal Aziz', 'MBBS, FCPS Nutrition', 'Nutrition Specialist', 'assets/images/doctor_sara.png', 4.8, 700),
];

