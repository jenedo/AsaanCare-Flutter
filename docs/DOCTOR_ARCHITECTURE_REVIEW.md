# Doctor Architecture Review

## Current findings

- The production doctor flow has one `MaterialApp` (`DoctorApp`) and one bottom navigation shell (`DoctorDashboardScreen`).
- The shell uses a five-child `IndexedStack` with stable Home, Schedule, Patients, Earnings, and Profile indexes.
- Dashboard metrics and quick actions switch shell state; they do not push another dashboard.
- `DoctorEarningsScreen` is the canonical index-3 destination. `DoctorWalletScreen` is an internal finance view that receives the same controller and an `onBack` callback.
- Patient routing remains in `AppRouter`; no doctor tab routes were added.
- The standalone `lib/doctor/screens/earnings/dashboard.dart` is untracked demo code with a separate app root and is not referenced by production.
- Dashboard mutation persistence and duplicate-action prevention live in the controller/datasource layers. Finance is read-only mock data with no simulated transfer or withdrawal mutation.

## Problems and risks

- Several doctor presentation files are large and should be decomposed only in later, behavior-preserving refactors.
- Responsive cards previously overflowed at 320px; grid ratios and Material surfaces were corrected, but the full width/text-scale matrix remains a release gate.
- Repeated responsive widget mounts now use isolated controller lifecycle
  handling in the doctor test harness.
- Profile data remains legacy presentation data and is outside the finance integration scope.
- An unrelated uncommitted auth mock introduces a doctor demo credential; it is excluded from the backup commit and must not be treated as authorization for sensitive actions.
- The demo earnings dashboard can be accidentally imported because it lives near production files; production imports and structural tests must continue to exclude it.
- The full repository test command exceeds the required three-minute ceiling;
  after inspection, the single serial/expanded retry also timed out without
  emitting a failing test. Focused doctor tests and static analysis are green.

## Target architecture

- Keep immutable domain models and repository/use-case boundaries under `doctor/features/dashboard` and `doctor/features/finance`.
- Keep `DoctorApp` as authenticated controller owner and `DoctorDashboardScreen` as navigation orchestrator.
- Keep home widgets presentation-only and controller-derived; show at most two pending requests and three upcoming appointments.
- Keep finance values as integer PKR and Wallet actions capability-gated until a verified backend contract provides authentication, authorization, balance checks, idempotency, audit logging, and replay protection.
- Use Material 3 surfaces, visible ink feedback, semantic labels, 44–48px targets, restrained teal emphasis, dark mode, centered web constraints, and reduced-motion behavior.

## Phased completion plan

1. Architecture stabilization: retain fixed interfaces, finish deterministic controller/repository tests, and remove stale widget-test assumptions.
2. Dashboard integration: verify every metric/action/tab index, filter handoff, request deduplication, reject confirmation, and appointment transitions.
3. Finance integration: verify canonical Earnings, real Wallet switching/back behavior, periods, filters, error/empty states, and payout gating.
4. UI/UX quality: validate 320/360/393/430/768/web widths, text scale, light/dark, semantics, keyboard/touch feedback, and reduced motion.
5. Release review: security/diff review, scoped format, analyzer, focused tests, full suite, memory update, final commit, and non-force push.

## Verification record

- `dart format`: 29 scoped Dart files checked.
- `flutter analyze`: no issues.
- Focused controller/Dashboard/Earnings/Wallet suite: 24 tests passed.
- Responsive widget coverage includes 320, 360, 393, 430, 768, and 1200
  logical-pixel widths.
- Repository-wide `flutter test`: timed out under the command-duration policy
  on the initial run and the one permitted retry; no failure output was
  produced.
- Structural scan confirms canonical Earnings and Wallet contain no `main()`,
  `MaterialApp`, or bottom navigation. The only production doctor bottom
  navigation remains the five-index Dashboard shell.
- Security review confirms payout/transfer actions stay capability-gated, PKR
  values remain integer rupees, backend exception details are not exposed to
  users, and unrelated mock credentials remain outside the scoped commits.

## Design handoff status

- Editable Figma file:
  https://www.figma.com/design/kxeuyxUvyL3vdjoteOz1xw
- A Starter-plan-safe token foundation was created with hidden primitives,
  targeted semantic scopes, code syntax metadata, and separate Light/Dark
  single-mode collections.
- Additional project-derived typography/component/screen writes were rejected
  by tenant external-disclosure policy and were not retried.
- Code Connect was not created: the connected Starter/View plan lacks the
  Organization/Enterprise and published team-library capabilities required by
  that workflow.

## Modification boundaries and rollback

- Modify only doctor feature/screen/controller tests, doctor DI/app ownership, and the two review documents unless a failing release gate identifies a direct dependency.
- Do not modify patient routes, patient wallet, unrelated auth/register UI, generated plugin files, package dependencies, or the standalone demo dashboard.
- Roll back implementation changes with `git revert b691843` if reverting the entire backed-up doctor redesign. For uncommitted unrelated work, use the timestamped patch under `backups/codex/`; never reset the dirty worktree.
