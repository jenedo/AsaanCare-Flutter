class PrescribedMedicine {
  const PrescribedMedicine({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
    this.route,
    this.notes,
  });

  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;
  final String? route;
  final String? notes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrescribedMedicine &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          dosage == other.dosage &&
          frequency == other.frequency &&
          duration == other.duration &&
          instructions == other.instructions &&
          route == other.route &&
          notes == other.notes;

  @override
  int get hashCode =>
      name.hashCode ^
      dosage.hashCode ^
      frequency.hashCode ^
      duration.hashCode ^
      instructions.hashCode ^
      route.hashCode ^
      notes.hashCode;
}
