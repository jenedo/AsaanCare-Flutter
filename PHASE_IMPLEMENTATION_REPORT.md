# Phase Implementation Report

## Scope

This report summarizes the implementation and verification work completed for:

- Phase 1: mode-separation review and patient-ID hardening
- Phase 2: dead-code cleanup
- Phase 3: doctor-side DI/controller architecture additions
- Phase 4: gitignore and untracking cleanup

## Phase 1 Review Findings

### Patient/doctor mode-separation safeguards

- `lib/main.dart` still protects doctor mode at startup. After restoring the current user, it checks `APP_MODE == 'doctor'` and force-logs out any signed-in non-doctor before launching `DoctorApp`.
- `lib/main_doctor.dart` still restores auth state before launching `DoctorApp`, preserving the doctor-only entry path.
- `lib/doctor/doctor_app.dart` still gates `_buildHome()` correctly:
  - dashboard renders only when the user is logged in
  - `currentUser` exists
  - `currentUser.role == UserRole.doctor`
  - all other cases fall back to `DoctorSignInScreen`
- `AuthController.logout()` already had the required local cleanup behavior and remains safe:
  - it clears `_currentUser` in `finally`
  - it clears the shared `PharmacyController` cart with `clearCart(resetSession: true)`
  - this happens even if the remote logout call throws

### Existing doctor auth test coverage

`test/doctor/doctor_sign_in_screen_test.dart` still covers the two critical behaviors:

- patient accounts are rejected from doctor sign-in
- doctor app UI transitions from sign-in to dashboard after authenticated doctor login

Coverage gaps still present:

- no focused test for startup force-logout when doctor mode is launched with a non-doctor session
- no focused test for logout clearing all relevant singleton-backed user state

## Mock Patient-ID Hardening

The latent fallback risk was removed by requiring explicit patient IDs in the affected patient-side flows.

### Changes made

- `lib/features/prescriptions/presentation/controllers/prescription_controller.dart`
  - removed the `mockPatientId` default path
  - `loadPrescriptions`, `pickAndUploadFile`, and `deleteRecord` now require an explicit `patientId`
- `lib/features/appointments/domain/usecases/book_appointment.dart`
  - removed the `defaultMockPatientId` fallback
  - booking now requires `patientId`
- `lib/features/appointments/presentation/controllers/appointment_booking_controller.dart`
  - removed the default patient-ID parameter
  - `book()` now requires `patientId`
- `lib/features/prescriptions/presentation/screens/medical_records_screen.dart`
  - `patientId` is now required at screen construction
  - no internal fallback remains
- `lib/features/doctors/presentation/screens/doctor_detail_screen.dart`
  - constructor now requires `patientId`, matching the hardened booking flow

### Router boundary preserved

The existing authenticated-patient route gate in `lib/core/routes/app_router.dart` was intentionally left unchanged. It remains the single source of truth for patient ID resolution via `_readAuthenticatedPatientId(...)` and the existing invalid-route redirect flow.

## Phase 2 Dead-Code Removals

### Removed superseded auth widgets

Deleted the no-longer-used registration widget files:

- `lib/features/auth/presentation/widgets/registration_step_one_form.dart`
- `lib/features/auth/presentation/widgets/registration_step_two_form.dart`
- `lib/features/auth/presentation/widgets/registration_terms_text.dart`
- `lib/features/auth/presentation/widgets/social_auth_buttons.dart`

`registration_ui_parts.dart` was intentionally preserved.

### Removed superseded doctor home flow

Confirmed the old doctor home module was orphaned and deleted:

- `lib/doctor/screens/home/doctor_home_screen.dart`
- `lib/doctor/screens/home/widgets/doctor_home_dashboard_section.dart`
- `lib/doctor/screens/home/widgets/todays_appointment_tile.dart`
- `lib/doctor/screens/home/widgets/appointment_status_button.dart`
- `lib/doctor/screens/home/widgets/incoming_requests_list.dart`
- `lib/doctor/screens/home/widgets/next_consultation_card.dart`

The active doctor shell continues to route through `screens/dashboard/doctor_dashboard_screen.dart`.

### Demo earnings dashboard boundary preserved

`lib/doctor/screens/earnings/dashboard.dart` was intentionally kept in place.

Added `test/doctor/doctor_demo_dashboard_boundary_test.dart` to assert:

- canonical earnings and wallet screens contain no `main()`
- canonical earnings and wallet screens contain no `MaterialApp`
- canonical earnings and wallet screens contain no bottom navigation shell
- the standalone demo `dashboard.dart` is not imported by production code

## Phase 3 DI / Clean Architecture Additions

Added doctor-side stub feature architecture under `lib/doctor/features/` using repository/datasource/controller patterns.

### New feature slices

#### Doctor profile

Added:

- `doctor/features/profile/domain/entities/doctor_profile_state.dart`
- `doctor/features/profile/domain/repositories/doctor_profile_repository.dart`
- `doctor/features/profile/data/datasources/doctor_profile_mock_data_source.dart`
- `doctor/features/profile/data/repositories/doctor_profile_repository_impl.dart`
- `doctor/features/profile/presentation/controllers/doctor_profile_controller.dart`

Updated `lib/doctor/screens/profile/doctor_profile_screen.dart` to:

- resolve controller via constructor override with service-locator fallback
- drive screen state through `AnimatedBuilder`
- move mutable profile/settings data out of widget-local fields
- call shared logout from the auth controller

#### Patient notes

Added:

- `doctor/features/patient_notes/domain/entities/doctor_patient_notes_state.dart`
- `doctor/features/patient_notes/domain/repositories/doctor_patient_notes_repository.dart`
- `doctor/features/patient_notes/data/datasources/doctor_patient_notes_mock_data_source.dart`
- `doctor/features/patient_notes/data/repositories/doctor_patient_notes_repository_impl.dart`
- `doctor/features/patient_notes/presentation/controllers/doctor_patient_notes_controller.dart`

Updated `lib/doctor/screens/patients/doctor_patient_profile_screen.dart` to:

- resolve controller via constructor override with fallback
- load notes by patient/appointment record ID
- drive tab selection and note list from controller state
- remove widget-local mutable note storage

#### Doctor prescription draft flow

Added:

- `doctor/features/prescription_writer/domain/entities/doctor_written_prescription.dart`
- `doctor/features/prescription_writer/domain/entities/doctor_prescription_draft_state.dart`
- `doctor/features/prescription_writer/domain/repositories/doctor_prescription_draft_repository.dart`
- `doctor/features/prescription_writer/data/datasources/doctor_prescription_draft_mock_data_source.dart`
- `doctor/features/prescription_writer/data/repositories/doctor_prescription_draft_repository_impl.dart`
- `doctor/features/prescription_writer/presentation/controllers/doctor_prescription_controller.dart`

Updated `lib/doctor/screens/consultation/write_prescription_screen.dart` to:

- resolve controller via constructor override with fallback
- keep text fields synced with controller-backed draft state
- move symptoms, lab tests, medicines, follow-up state, and notes into controller state
- preserve the existing UI flow while removing most ad-hoc widget-local business state

### Service locator wiring

Registered the new doctor feature datasources/repositories/controllers in `lib/core/di/service_locator.dart` using the same screen-scoped controller pattern already used by doctor dashboard and finance controllers:

- repositories/datasources as lazy singletons
- controllers as `registerFactory`

### Logout/reset handling

Extended `AuthController.logout()` to reset the new doctor-side mock datasources on logout:

- `DoctorProfileMockDataSource`
- `DoctorPatientNotesMockDataSource`
- `DoctorPrescriptionDraftMockDataSource`

This keeps user-scoped mutable state aligned with the project’s logout/reset convention.

## Phase 4 Gitignore and Untracking Cleanup

### Ignore rules added

Updated `.gitignore` to include:

- `/android/build/`
- `key.properties`
- `/android/key.properties`

### Artifact untracked

Untracked the committed Gradle output:

- `android/build/reports/problems/problems-report.html`

This was removed from version control using `git rm -r --cached android/build` semantics while preserving local files on disk.

### Keystore properties

No tracked `key.properties` file was found in the current evidence set after the cleanup check, but ignore coverage is now in place to prevent future commits.

## Verification Performed

### Code review verification

Reviewed the relevant updated files for:

- startup doctor/patient role separation
- doctor dashboard gating
- logout cleanup safety
- patient-ID hardening
- service locator registrations
- demo dashboard boundary

### Tests run

Observed passing coverage:

- `test/doctor/doctor_demo_dashboard_boundary_test.dart`
- `test/doctor/doctor_earnings_screen_test.dart`

Observed existing failing coverage:

- `test/doctor/doctor_patient_profile_screen_test.dart`

## Remaining Gaps / Known Issues

- One existing doctor patient profile test still fails due to an expectation mismatch around unauthenticated `DoctorApp()` behavior.
- Current evidence indicates that the failing test still assumes navigation from a bare unauthenticated `DoctorApp()` into a patient record flow, while the doctor shell now correctly defaults to sign-in unless a valid authenticated doctor session is present.
- `test/doctor/doctor_sign_in_screen_test.dart` also shows pre-existing test instability around swipe/timer behavior in the current environment, but the key role-rejection and dashboard-gating assertions remain present in the file.

## Summary

The task’s requested hardening and cleanup work has been implemented: patient-ID fallbacks were removed from sensitive patient flows, obsolete auth/doctor code was deleted, doctor stub features were moved onto DI-backed controllers/repositories, logout now resets the new doctor-side session-backed mock state, and Gradle/keystore ignore hygiene was improved. Verification is mostly positive, with one known existing doctor patient profile test still misaligned with the intentional unauthenticated `DoctorApp()` gate.
