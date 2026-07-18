# AsaanCare Project Memory

Last updated: 2026-07-17

## Project map

- Branch: `AsaanCare`; remote: `origin` at the existing Health-- GitHub repository.
- Primary entry point: `lib/main.dart`. `APP_MODE=doctor` selects `DoctorApp`; patient mode continues through `AsaanCareApp` and `AppRouter`.
- Doctor-only entry point: `lib/main_doctor.dart`; it initializes get_it, restores authentication, and runs `DoctorApp`.
- Doctor shell: `DoctorDashboardScreen` in `lib/doctor/screens/dashboard/doctor_dashboard_screen.dart`.
- Fixed shell indexes: Home `0`, Schedule `1`, Patients `2`, Earnings `3`, Profile `4`.
- Canonical finance screens: `DoctorEarningsScreen` and `DoctorWalletScreen` in `lib/doctor/screens/earnings/`.
- Profile screen: `DoctorProfileScreen` in `lib/doctor/screens/profile/doctor_profile_screen.dart` with `showBackButton: false` in the shell.
- `lib/doctor/screens/earnings/dashboard.dart` is a standalone demo containing its own app root and must never be imported into production.

## Architecture and ownership

- Doctor dashboard and finance use immutable domain entities, repository interfaces, use cases, mock datasources, repository implementations, and `ChangeNotifier` controllers.
- get_it registers datasources/repositories/use cases as lazy singletons and both doctor controllers as factories.
- `DoctorApp` resolves and caches controllers only after an authenticated doctor session. It disposes internally resolved controllers and never disposes injected test controllers.
- Dashboard mock state is keyed by authenticated doctor ID and persists request/status mutations for the datasource lifetime.
- Finance values are integer PKR amounts. Withdraw and transfer capabilities remain disabled until authenticated, idempotent payout APIs exist.
- Earnings opens Wallet with the same finance controller via `AnimatedSwitcher`; the shell navigation remains mounted at index `3`.

## Theme, routing, and compatibility

- `DoctorApp` owns doctor light/dark `ThemeMode` and Material 3 `ColorScheme.fromSeed` themes. The dashboard header toggles this state.
- Patient routes in `AppRoutes` and `AppRouter` are unchanged. Doctor tabs are internal shell destinations and must not be added as named routes.
- Existing consultation, prescription, patient profile, patient app, and patient wallet flows remain separate.

## Verification commands

- `dart format <changed Dart files>`
- `flutter analyze`
- `flutter test test/doctor/features/dashboard/doctor_dashboard_controller_test.dart test/doctor/features/finance/doctor_finance_controller_test.dart`
- `flutter test test/doctor/doctor_dashboard_screen_test.dart test/doctor/doctor_earnings_screen_test.dart test/doctor/doctor_wallet_screen_test.dart`
- `flutter test`

## Current state and decisions

- Final analyzer status: no issues.
- Focused doctor verification: 24 tests pass across controller, Dashboard,
  Earnings, and Wallet suites.
- The repository-wide `flutter test` gate exceeded the required three-minute
  ceiling. The first run was stopped for inspection and the single permitted
  serial/expanded retry was terminated by the shell wrapper at 244 seconds
  without emitting a test failure. This gate is recorded as timed out, not
  passed.
- Backup push: `b691843` pushed to `origin/AsaanCare` without force.
- Local backups: timestamped tracked patch and important-untracked-source manifest under `backups/codex/`.
- Material icons and existing approved assets are preferred; no generated visual asset is required.
- Reduced motion disables decorative `flutter_animate` transitions. Native sheets/dialogs provide confirmation and safety messaging.
- Figma artifact: [AsaanCare Doctor Dashboard & Finance](https://www.figma.com/design/kxeuyxUvyL3vdjoteOz1xw)
  contains an editable, idempotently tagged token foundation. Because the
  connected Starter plan cannot create variable modes, Light and Dark use
  separate single-mode semantic collections aliased to hidden primitives.
  Further external writes were denied by tenant data-disclosure policy and
  were not retried.
- Figma Code Connect remains unavailable because the connected Starter/View
  plan does not satisfy its Organization/Enterprise and published-library
  prerequisites.
- Known debt: the doctor home, earnings, wallet, and profile presentation files are large; profile contains legacy hardcoded presentation data; the full repository suite exceeds the mandated command-duration ceiling; unrelated auth/register changes and generated plugin files remain outside this task.
- Security debt outside the scoped backup: an uncommitted mock doctor credential exists in the unrelated auth datasource and must not be committed or used as a finance authorization mechanism.

## Phase history

- Protection: created local patch/manifest, reviewed staged content, created and pushed backup commit `b691843`.
- Architecture: added dashboard/finance feature layers and DI registrations.
- Integration: connected the five shell pages and all Earnings entries to index `3`.
- Finance: implemented canonical controller-driven Earnings and Wallet with gated actions.
- Verification: analyzer is clean and 24 focused doctor tests are green; the
  repository-wide suite timed out under the enforced duration policy after one
  inspected retry.
