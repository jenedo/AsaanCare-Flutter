class DoctorPatientNotesState {
  const DoctorPatientNotesState({
    this.selectedTab = 0,
    this.notes = const [
      'Patient responded well to antibiotics. Follow up in 2 weeks if symptoms persist.',
    ],
  });

  final int selectedTab;
  final List<String> notes;

  DoctorPatientNotesState copyWith({int? selectedTab, List<String>? notes}) {
    return DoctorPatientNotesState(
      selectedTab: selectedTab ?? this.selectedTab,
      notes: notes ?? this.notes,
    );
  }
}
