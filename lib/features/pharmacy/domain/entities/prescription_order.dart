class PrescriptionOrder {
  const PrescriptionOrder({
    required this.id,
    required this.title,
    required this.uploadedDate,
    required this.isVerified,
    required this.imageAsset,
    required this.medicineIds,
  });

  final String id;
  final String title;
  final String uploadedDate;
  final bool isVerified;
  final String imageAsset;
  final List<String> medicineIds;
}
