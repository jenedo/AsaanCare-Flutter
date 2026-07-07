class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.qualification,
    required this.specialty,
    required this.imageAsset,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.consultationFee,
    required this.patientsCount,
    required this.about,
    required this.isVerified,
  });

  final String id;
  final String name;
  final String qualification;
  final String specialty;
  final String imageAsset;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final int consultationFee;
  final int patientsCount;
  final String about;
  final bool isVerified;
}
