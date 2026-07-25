import '../../domain/entities/prescribed_medicine.dart';

class PrescribedMedicineModel extends PrescribedMedicine {
  const PrescribedMedicineModel({
    required super.name,
    required super.dosage,
    required super.frequency,
    required super.duration,
    super.instructions,
    super.route,
    super.notes,
  });

  factory PrescribedMedicineModel.fromJson(Map<String, dynamic> json) {
    return PrescribedMedicineModel(
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      instructions: json['instructions'] as String?,
      route: json['route'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      if (instructions != null) 'instructions': instructions,
      if (route != null) 'route': route,
      if (notes != null) 'notes': notes,
    };
  }
}
