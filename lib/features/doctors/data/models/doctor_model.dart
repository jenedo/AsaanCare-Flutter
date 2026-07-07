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
}
