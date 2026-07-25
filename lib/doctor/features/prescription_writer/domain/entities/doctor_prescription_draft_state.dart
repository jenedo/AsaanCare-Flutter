import 'doctor_written_prescription.dart';

class DoctorPrescriptionDraftState {
  const DoctorPrescriptionDraftState({
    this.diagnosis = 'Upper Respiratory Infection',
    this.chiefComplaint = 'Fever, sore throat, cough for 3 days',
    this.doctorNotes =
        'Advise rest, hydration, warm fluids, and complete antibiotic course. Return earlier if symptoms worsen.',
    this.symptoms = const ['Fever', 'Cough', 'Sore Throat', 'Body Aches'],
    this.labTests = const ['CBC (Complete Blood Count)', 'ECG'],
    this.medicines = const [
      DoctorWrittenPrescription(
        name: 'Amoxicillin',
        dosage: '500mg',
        frequency: 'After meal',
        duration: '7 days',
        instructions: 'Take with water',
      ),
      DoctorWrittenPrescription(
        name: 'Paracetamol',
        dosage: '500mg',
        frequency: 'As needed',
        duration: '5 days',
        instructions: 'For fever and pain',
      ),
    ],
    this.followUp = true,
    this.followUpAfter = '2 weeks',
  });

  final String diagnosis;
  final String chiefComplaint;
  final String doctorNotes;
  final List<String> symptoms;
  final List<String> labTests;
  final List<DoctorWrittenPrescription> medicines;
  final bool followUp;
  final String followUpAfter;

  DoctorPrescriptionDraftState copyWith({
    String? diagnosis,
    String? chiefComplaint,
    String? doctorNotes,
    List<String>? symptoms,
    List<String>? labTests,
    List<DoctorWrittenPrescription>? medicines,
    bool? followUp,
    String? followUpAfter,
  }) {
    return DoctorPrescriptionDraftState(
      diagnosis: diagnosis ?? this.diagnosis,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      symptoms: symptoms ?? this.symptoms,
      labTests: labTests ?? this.labTests,
      medicines: medicines ?? this.medicines,
      followUp: followUp ?? this.followUp,
      followUpAfter: followUpAfter ?? this.followUpAfter,
    );
  }
}
