import 'dart:typed_data';

class DoctorRegistrationPayload {
  const DoctorRegistrationPayload({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.gender,
    required this.specialty,
    required this.pmdcOrLicenseNumber,
    required this.yearsOfExperience,
    required this.hospitalOrClinicName,
    required this.consultationFeePkr,
    required this.medicalLicense,
    required this.idFront,
    required this.idBack,
  });

  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String gender;
  final String specialty;
  final String pmdcOrLicenseNumber;
  final int yearsOfExperience;
  final String hospitalOrClinicName;
  final int consultationFeePkr;
  final RegistrationUpload medicalLicense;
  final RegistrationUpload idFront;
  final RegistrationUpload idBack;
}

class RegistrationUpload {
  const RegistrationUpload({
    required this.name,
    required this.bytes,
    required this.extension,
  });

  final String name;
  final Uint8List bytes;
  final String extension;

  bool get isImage => extension != 'pdf';
}
