# =============================================================================
# AsaanCare PR #1 — Confirmed Bug Fix Script
# Fixes: 6 confirmed findings from code review
# Target branch: pharmacy-consolidated-fix-20260708
# Head commit: bfbfc0fb
# =============================================================================
# HOW TO RUN:
#   Set-Location "D:\VP\Project\Health--"
#   powershell -ExecutionPolicy Bypass -File "C:\Users\Fareed Ahmed\Downloads\fix_asaancare_pr1.ps1"
# =============================================================================

param(
    [string]$RepoPath = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Colours ──────────────────────────────────────────────────────────────────
function Write-OK   { param($m) Write-Host "[OK]   $m" -ForegroundColor Green  }
function Write-INFO { param($m) Write-Host "[INFO] $m" -ForegroundColor Cyan   }
function Write-FAIL { param($m) Write-Host "[FAIL] $m" -ForegroundColor Red    }
function Write-STEP { param($m) Write-Host "`n=== $m ===" -ForegroundColor Yellow }

# ── Safety checks ────────────────────────────────────────────────────────────
Write-STEP "Safety checks"

Set-Location $RepoPath
Write-OK "Working directory: $RepoPath"

$branch = git rev-parse --abbrev-ref HEAD 2>&1
if ($branch -ne "pharmacy-consolidated-fix-20260708") {
    Write-FAIL "Wrong branch. Expected 'pharmacy-consolidated-fix-20260708', got '$branch'"
    Write-FAIL "Run: git checkout pharmacy-consolidated-fix-20260708"
    exit 1
}
Write-OK "Branch: $branch"

$status = git status --porcelain 2>&1
if ($status) {
    Write-FAIL "Uncommitted changes detected. Commit or stash first."
    git status --short
    exit 1
}
Write-OK "Working tree clean"

$head = git rev-parse --short HEAD 2>&1
Write-INFO "Head commit: $head"

# ── File path helpers ─────────────────────────────────────────────────────────
$libCore        = Join-Path $RepoPath "lib\core"
$libFeatures    = Join-Path $RepoPath "lib\features"
$testCore       = Join-Path $RepoPath "test\core"
$testPharmacy   = Join-Path $RepoPath "test\features\pharmacy"
$ciWorkflow     = Join-Path $RepoPath ".github\workflows\flutter_ci.yml"

# ── FIX 1: AppConfig — reject non-local HTTP in remote mode ──────────────────
Write-STEP "Fix 1/5 — AppConfig: enforce HTTPS in remote mode"

$appConfigPath = Join-Path $libCore "config\app_config.dart"
if (-not (Test-Path $appConfigPath)) {
    Write-FAIL "File not found: $appConfigPath"
    exit 1
}

$appConfigNew = @'
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

abstract final class AppConfig {
  const AppConfig._();

  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: true,
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const int requestTimeoutSeconds = int.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: 20,
  );

  static Duration get requestTimeout =>
      Duration(seconds: requestTimeoutSeconds);

  static void validate() {
    if (useMockApi) return;
    validateValues(
      useMockApi: useMockApi,
      apiBaseUrl: apiBaseUrl,
      requestTimeoutSeconds: requestTimeoutSeconds,
      allowLocalHttp: kDebugMode,
    );
  }

  @visibleForTesting
  static void validateValues({
    required bool useMockApi,
    required String apiBaseUrl,
    required int requestTimeoutSeconds,
    required bool allowLocalHttp,
  }) {
    if (useMockApi) return;

    final uri = Uri.tryParse(apiBaseUrl.trim());

    final isHttps = uri?.scheme == 'https';
    final isAllowedLocalHttp =
        allowLocalHttp &&
        uri?.scheme == 'http' &&
        const {'localhost', '127.0.0.1', '10.0.2.2'}.contains(uri?.host);
    final validScheme = isHttps || isAllowedLocalHttp;

    if (uri == null || !uri.hasAuthority || !validScheme) {
      throw StateError(
        'Remote API mode requires HTTPS. '
        'Plain HTTP is only allowed for localhost / 127.0.0.1 / 10.0.2.2 '
        'in debug builds. Got: $apiBaseUrl',
      );
    }

    if (requestTimeoutSeconds < 5 || requestTimeoutSeconds > 120) {
      throw StateError(
        'API_TIMEOUT_SECONDS must be between 5 and 120 seconds.',
      );
    }
  }
}
'@

Set-Content -Path $appConfigPath -Value $appConfigNew -Encoding UTF8
Write-OK "app_config.dart rewritten"

# Check if meta package is already in pubspec
$pubspecPath = Join-Path $RepoPath "pubspec.yaml"
$pubspecContent = Get-Content $pubspecPath -Raw
if ($pubspecContent -notmatch "meta:") {
    # meta is a transitive dep of flutter — no need to add explicitly
    # but @visibleForTesting comes from meta package
    # It is already available as flutter includes meta transitively
    Write-INFO "meta package available transitively via flutter sdk — no pubspec change needed"
}
Write-OK "meta package available via flutter (transitive)"

# ── FIX 2: AppConfig tests ────────────────────────────────────────────────────
Write-STEP "Fix 2/5 — Add AppConfig unit tests"

$configTestDir = Join-Path $testCore "config"
if (-not (Test-Path $configTestDir)) {
    New-Item -ItemType Directory -Path $configTestDir | Out-Null
}

$configTestPath = Join-Path $configTestDir "app_config_test.dart"
$configTestContent = @'
import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/core/config/app_config.dart';

void main() {
  group('AppConfig.validateValues', () {
    test('mock mode skips all validation', () {
      // Should not throw regardless of other params.
      AppConfig.validateValues(
        useMockApi: true,
        apiBaseUrl: 'http://evil.example.com',
        requestTimeoutSeconds: 0,
        allowLocalHttp: false,
      );
    });

    test('HTTPS URL passes in remote mode', () {
      AppConfig.validateValues(
        useMockApi: false,
        apiBaseUrl: 'https://api.asaancare.pk',
        requestTimeoutSeconds: 20,
        allowLocalHttp: false,
      );
    });

    test('plain HTTP rejects in remote mode', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'http://api.asaancare.pk',
          requestTimeoutSeconds: 20,
          allowLocalHttp: false,
        ),
        throwsStateError,
      );
    });

    test('localhost HTTP allowed when allowLocalHttp is true', () {
      for (final host in ['localhost', '127.0.0.1', '10.0.2.2']) {
        AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'http://$host:8080',
          requestTimeoutSeconds: 20,
          allowLocalHttp: true,
        );
      }
    });

    test('localhost HTTP rejected when allowLocalHttp is false', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'http://localhost:8080',
          requestTimeoutSeconds: 20,
          allowLocalHttp: false,
        ),
        throwsStateError,
      );
    });

    test('empty URL rejects in remote mode', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: '',
          requestTimeoutSeconds: 20,
          allowLocalHttp: false,
        ),
        throwsStateError,
      );
    });

    test('timeout below 5 rejects', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'https://api.asaancare.pk',
          requestTimeoutSeconds: 4,
          allowLocalHttp: false,
        ),
        throwsStateError,
      );
    });

    test('timeout above 120 rejects', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'https://api.asaancare.pk',
          requestTimeoutSeconds: 121,
          allowLocalHttp: false,
        ),
        throwsStateError,
      );
    });
  });
}
'@

Set-Content -Path $configTestPath -Value $configTestContent -Encoding UTF8
Write-OK "test/core/config/app_config_test.dart created"

# ── FIX 3: PharmacyController — complete resetSession ────────────────────────
Write-STEP "Fix 3/5 — PharmacyController: reset recentPrescription and status on logout"

$controllerPath = Join-Path $libFeatures "pharmacy\presentation\controllers\pharmacy_controller.dart"
if (-not (Test-Path $controllerPath)) {
    Write-FAIL "File not found: $controllerPath"
    exit 1
}

$controllerContent = Get-Content $controllerPath -Raw

# The exact block to find and replace
$oldBlock = @'
    if (resetSession) {
      _favoriteIds.clear();
      _activeOrder = null;
      _paymentMethod = PharmacyPaymentMethod.cashOnDelivery;
      _deliveryAddress = '123, Model Town, Block B, Lahore, Punjab 54000';
      _selectedPharmacy = 'MediPlus Pharmacy';
      _selectedCity = 'Lahore';
      _errorMessage = null;
      _isPlacingOrder = false;
    }
'@

$newBlock = @'
    if (resetSession) {
      _favoriteIds.clear();
      _activeOrder = null;
      _recentPrescription = null;
      _status = PharmacyStatus.initial;
      _paymentMethod = PharmacyPaymentMethod.cashOnDelivery;
      _deliveryAddress = '123, Model Town, Block B, Lahore, Punjab 54000';
      _selectedPharmacy = 'MediPlus Pharmacy';
      _selectedCity = 'Lahore';
      _errorMessage = null;
      _isPlacingOrder = false;
    }
'@

if ($controllerContent -notlike "*$oldBlock*") {
    # Try exact string match with literal comparison
    if (-not $controllerContent.Contains($oldBlock.Trim())) {
        Write-FAIL "Could not find expected clearCart block in pharmacy_controller.dart"
        Write-FAIL "Manual edit required — see review for exact change"
        exit 1
    }
}

$controllerContent = $controllerContent.Replace($oldBlock, $newBlock)
Set-Content -Path $controllerPath -Value $controllerContent -Encoding UTF8 -NoNewline
Write-OK "clearCart(resetSession:true) now resets _recentPrescription and _status"

# ── FIX 3b: Strengthen session reset test ─────────────────────────────────────
Write-STEP "Fix 3b/5 — Strengthen pharmacy_session_reset_test.dart"

$sessionTestPath = Join-Path $testPharmacy "pharmacy_session_reset_test.dart"
if (-not (Test-Path $sessionTestPath)) {
    Write-FAIL "File not found: $sessionTestPath"
    exit 1
}

$sessionTestContent = Get-Content $sessionTestPath -Raw

# Add two new assertions to the existing first test, after "expect(controller.errorMessage, isNull);"
$oldAssertions = @'
      expect(controller.isCartEmpty, isTrue);
      expect(controller.isFavorite(medicine.id), isFalse);
      expect(
        controller.selectedPaymentMethod,
        PharmacyPaymentMethod.cashOnDelivery,
      );
      expect(controller.selectedCity, 'Lahore');
      expect(controller.activeOrder, isNull);
      expect(controller.errorMessage, isNull);
'@

$newAssertions = @'
      expect(controller.isCartEmpty, isTrue);
      expect(controller.isFavorite(medicine.id), isFalse);
      expect(
        controller.selectedPaymentMethod,
        PharmacyPaymentMethod.cashOnDelivery,
      );
      expect(controller.selectedCity, 'Lahore');
      expect(controller.activeOrder, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.recentPrescription, isNull);
      expect(controller.status, PharmacyStatus.initial);
'@

if (-not $sessionTestContent.Contains($oldAssertions)) {
    Write-FAIL "Could not find assertion block in pharmacy_session_reset_test.dart — check manually"
    exit 1
}

$sessionTestContent = $sessionTestContent.Replace($oldAssertions, $newAssertions)
Set-Content -Path $sessionTestPath -Value $sessionTestContent -Encoding UTF8 -NoNewline
Write-OK "pharmacy_session_reset_test.dart — added recentPrescription and status assertions"

# ── FIX 4: PatientProfileScreen — mounted check after bottom sheet ────────────
Write-STEP "Fix 4/5 — PatientProfileScreen: mounted guard after showModalBottomSheet"

$profilePath = Join-Path $libFeatures "patient\presentation\screens\patient_profile_screen.dart"
if (-not (Test-Path $profilePath)) {
    Write-FAIL "File not found: $profilePath"
    exit 1
}

$profileContent = Get-Content $profilePath -Raw

$oldGuard = '    if (selected == null || selected == _language) return;'
$newGuard = '    if (!mounted || selected == null || selected == _language) return;'

if (-not $profileContent.Contains($oldGuard)) {
    Write-FAIL "Could not find guard line in patient_profile_screen.dart"
    exit 1
}

$profileContent = $profileContent.Replace($oldGuard, $newGuard)
Set-Content -Path $profilePath -Value $profileContent -Encoding UTF8 -NoNewline
Write-OK "patient_profile_screen.dart — mounted check added"

# ── FIX 5: AppRouter — remove dead mockPatientId fallback ────────────────────
Write-STEP "Fix 5/5 — AppRouter: remove dead mockPatientId fallback"

$routerPath = Join-Path $libCore "routes\app_router.dart"
if (-not (Test-Path $routerPath)) {
    Write-FAIL "File not found: $routerPath"
    exit 1
}

$routerContent = Get-Content $routerPath -Raw

$oldFallback = @'
      case AppRoutes.medicalRecords:
        final patientId =
            authController.currentUser?.id ??
            PrescriptionController.mockPatientId;

        return _smoothRoute(
'@

$newFallback = @'
      case AppRoutes.medicalRecords:
        final patientId = authController.currentUser!.id;

        return _smoothRoute(
'@

if (-not $routerContent.Contains($oldFallback)) {
    Write-FAIL "Could not find medicalRecords patientId block in app_router.dart"
    exit 1
}

$routerContent = $routerContent.Replace($oldFallback, $newFallback)
Set-Content -Path $routerPath -Value $routerContent -Encoding UTF8 -NoNewline
Write-OK "app_router.dart — dead mockPatientId fallback removed"

# ── FIX 6: CI Workflow — remove feature branch push trigger ──────────────────
Write-STEP "Fix 6/6 — CI: remove duplicate-run trigger for feature branch"

if (-not (Test-Path $ciWorkflow)) {
    Write-FAIL "File not found: $ciWorkflow"
    exit 1
}

$ciNew = @'
name: Flutter CI

on:
  pull_request:
  push:
    branches:
      - main

permissions:
  contents: read

concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.head.ref || github.ref_name }}
  cancel-in-progress: true

jobs:
  validate:
    runs-on: ubuntu-latest
    timeout-minutes: 25

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          persist-credentials: false

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Verify formatting
        run: dart format --output=none --set-exit-if-changed lib test

      - name: Analyze
        run: flutter analyze

      - name: Test
        run: flutter test

      - name: Build web
        run: flutter build web --release
'@

Set-Content -Path $ciWorkflow -Value $ciNew -Encoding UTF8
Write-OK "flutter_ci.yml — feature branch push trigger removed, concurrency group added, persist-credentials disabled"

# ── Verify dart format ────────────────────────────────────────────────────────
Write-STEP "Verify: dart format"

$dartCmd = Get-Command dart -ErrorAction SilentlyContinue
if ($null -eq $dartCmd) {
    Write-INFO "dart not found in PATH — skipping format check"
    Write-INFO "Run manually: dart format lib test"
} else {
    dart format lib test
    Write-OK "dart format completed"
}

# ── Verify flutter analyze ────────────────────────────────────────────────────
Write-STEP "Verify: flutter analyze"

$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if ($null -eq $flutterCmd) {
    Write-INFO "flutter not found in PATH — skipping analyze"
    Write-INFO "Run manually: flutter analyze"
} else {
    flutter analyze
    if ($LASTEXITCODE -ne 0) {
        Write-FAIL "flutter analyze failed — check errors above before committing"
        exit 1
    }
    Write-OK "flutter analyze passed"
}

# ── Verify flutter test ───────────────────────────────────────────────────────
Write-STEP "Verify: flutter test"

if ($null -ne $flutterCmd) {
    flutter test
    if ($LASTEXITCODE -ne 0) {
        Write-FAIL "flutter test failed — check errors above before committing"
        exit 1
    }
    Write-OK "flutter test passed"
} else {
    Write-INFO "flutter not found in PATH — skipping tests"
    Write-INFO "Run manually: flutter test"
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-STEP "All patches applied"

Write-Host @"

Changes made:
  [1] lib/core/config/app_config.dart
      - Plain HTTP rejected in remote mode (HTTPS enforced)
      - localhost / 127.0.0.1 / 10.0.2.2 allowed in debug only
      - validateValues() extracted for unit testing

  [2] test/core/config/app_config_test.dart  (NEW FILE)
      - 8 unit tests covering HTTP rejection, HTTPS pass,
        localhost debug allowance, empty URL, timeout bounds

  [3] lib/features/pharmacy/presentation/controllers/pharmacy_controller.dart
      - clearCart(resetSession:true) now resets _recentPrescription and _status

  [4] test/features/pharmacy/pharmacy_session_reset_test.dart
      - Added assertions for recentPrescription == null and status == initial

  [5] lib/features/patient/presentation/screens/patient_profile_screen.dart
      - Added mounted guard after showModalBottomSheet await

  [6] lib/core/routes/app_router.dart
      - Removed dead mockPatientId fallback (currentUser!.id used directly)

  [7] .github/workflows/flutter_ci.yml
      - Removed feature-branch push trigger (PR event covers it)
      - Added concurrency group to cancel superseded runs
      - Added persist-credentials: false

Next steps:
  git diff
  git add .
  git commit -m "fix: harden auth config pharmacy session and CI"
  git push origin pharmacy-consolidated-fix-20260708

"@ -ForegroundColor Cyan
