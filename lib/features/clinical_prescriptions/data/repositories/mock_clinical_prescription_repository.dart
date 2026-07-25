import '../../domain/entities/clinical_prescription.dart';
import '../../domain/entities/prescribed_medicine.dart';
import '../../domain/repositories/clinical_prescription_repository.dart';

class MockClinicalPrescriptionRepository
    implements ClinicalPrescriptionRepository {
  final List<ClinicalPrescription> _demoPrescriptions = [
    ClinicalPrescription(
      id: 'mock_clinical_presc_001',
      appointmentId: 'mock_appointment_001',
      doctorProfileId: 'mock_doctor_001',
      patientProfileId: 'mock_patient_001',
      status: ClinicalPrescriptionStatus.issued,
      version: 1,
      medicines: const [
        PrescribedMedicine(
          name: 'Panadol Extra',
          dosage: '500mg',
          frequency: 'Twice daily',
          duration: '5 days',
          instructions: 'Take after meals',
        ),
      ],
      instructions: 'Drink plenty of water and rest.',
      issuedAt: DateTime(2026, 7, 25, 10, 0),
      createdAt: DateTime(2026, 7, 25, 10, 0),
      doctorName: 'Dr. Ali Raza',
      doctorSpecialty: 'Cardiology',
      patientName: 'Ahmad Ali',
    ),
  ];

  @override
  Future<List<ClinicalPrescription>> getClinicalPrescriptions() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<ClinicalPrescription>.unmodifiable(_demoPrescriptions);
  }

  @override
  Future<ClinicalPrescription> getClinicalPrescription(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final match = _demoPrescriptions.firstWhere(
      (p) => p.id == id,
      orElse: () => throw StateError('Clinical prescription not found.'),
    );
    return match;
  }
}
