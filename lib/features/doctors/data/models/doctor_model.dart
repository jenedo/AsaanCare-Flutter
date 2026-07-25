import '../../domain/entities/doctor.dart';

class DoctorModel extends Doctor {
  const DoctorModel({
    required super.id,
    required super.name,
    required super.qualification,
    required super.specialty,
    required super.imageAsset,
    required super.rating,
    required super.reviewCount,
    required super.experienceYears,
    required super.consultationFee,
    required super.patientsCount,
    required super.about,
    required super.isVerified,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id']?.toString() ?? '',
      name:
          json['fullName']?.toString() ?? json['name']?.toString() ?? 'Doctor',
      qualification:
          json['qualification']?.toString() ??
          json['pmdcNumber']?.toString() ??
          'MBBS',
      specialty: json['specialty']?.toString() ?? 'General Physician',
      imageAsset:
          json['imageAsset']?.toString() ?? 'assets/images/doctor_sara.png',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 120,
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 5,
      consultationFee: (json['consultationFee'] as num?)?.toInt() ?? 1000,
      patientsCount: (json['patientsCount'] as num?)?.toInt() ?? 350,
      about: json['about']?.toString() ?? 'Verified healthcare practitioner.',
      isVerified: json['isVerified'] as bool? ?? true,
    );
  }
}
