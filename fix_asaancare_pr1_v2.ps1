param(
    [string]$RepoPath = "D:\VP\Project\Health-PR1-Fix"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== $Message ===" -ForegroundColor Yellow
}

function Write-Ok {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-InfoLine {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Read-NormalizedText {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Missing file: $Path"
    }

    return [System.IO.File]::ReadAllText($Path).Replace("`r`n", "`n")
}

function Write-Utf8NoBom {
    param(
        [string]$Path,
        [string]$Content
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Assert-Contains {
    param(
        [string]$Content,
        [string]$Expected,
        [string]$Description
    )

    if (-not $Content.Contains($Expected)) {
        throw "Expected code not found: $Description"
    }
}

function Run-Checked {
    param(
        [string]$Description,
        [scriptblock]$Command
    )

    Write-Step $Description
    & $Command

    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed with exit code $LASTEXITCODE"
    }

    Write-Ok "$Description passed"
}

Write-Step "Safety checks"

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "Repository folder not found: $RepoPath"
}

Set-Location -LiteralPath $RepoPath
Write-Ok "Repository: $RepoPath"

$branch = (& git branch --show-current).Trim()
if ($LASTEXITCODE -ne 0) {
    throw "Could not read the current Git branch."
}

$expectedBranch = "pharmacy-consolidated-fix-20260708"
if ($branch -ne $expectedBranch) {
    throw "Wrong branch: $branch. Expected: $expectedBranch"
}
Write-Ok "Branch: $branch"

$status = (& git status --porcelain)
if ($LASTEXITCODE -ne 0) {
    throw "Could not read Git status."
}

if ($status) {
    Write-Host $status
    throw "Working tree is not clean. No files were changed by this script."
}
Write-Ok "Working tree is clean"

$appConfigPath = Join-Path $RepoPath "lib\core\config\app_config.dart"
$pharmacyControllerPath = Join-Path $RepoPath "lib\features\pharmacy\presentation\controllers\pharmacy_controller.dart"
$profilePath = Join-Path $RepoPath "lib\features\patient\presentation\screens\patient_profile_screen.dart"
$routerPath = Join-Path $RepoPath "lib\core\routes\app_router.dart"
$sessionTestPath = Join-Path $RepoPath "test\features\pharmacy\pharmacy_session_reset_test.dart"
$configTestPath = Join-Path $RepoPath "test\core\config\app_config_test.dart"
$workflowPath = Join-Path $RepoPath ".github\workflows\flutter_ci.yml"

# Read and preflight all files before writing anything.
$pharmacyController = Read-NormalizedText $pharmacyControllerPath
$profile = Read-NormalizedText $profilePath
$router = Read-NormalizedText $routerPath
$sessionTest = Read-NormalizedText $sessionTestPath

$oldResetBlock = @'
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

$newResetBlock = @'
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

$oldMountedGuard = '    if (selected == null || selected == _language) return;'
$newMountedGuard = '    if (!mounted || selected == null || selected == _language) return;'

$oldRouterBlock = @'
      case AppRoutes.medicalRecords:
        final patientId =
            authController.currentUser?.id ??
            PrescriptionController.mockPatientId;

        return _smoothRoute(
'@

$newRouterBlock = @'
      case AppRoutes.medicalRecords:
        final patientId = authController.currentUser?.id.trim();

        if (patientId == null || patientId.isEmpty) {
          return _smoothRoute(
            settings: const RouteSettings(name: AppRoutes.login),
            child: LoginScreen(authController: authController),
          );
        }

        return _smoothRoute(
'@

$prescriptionControllerImport = "import '../../features/prescriptions/presentation/controllers/prescription_controller.dart';`n"

$oldSessionAssertions = @'
      expect(controller.activeOrder, isNull);
      expect(controller.errorMessage, isNull);
'@

$newSessionAssertions = @'
      expect(controller.activeOrder, isNull);
      expect(controller.recentPrescription, isNull);
      expect(controller.status, PharmacyStatus.initial);
      expect(controller.errorMessage, isNull);
'@

Assert-Contains $pharmacyController $oldResetBlock "PharmacyController resetSession block"
Assert-Contains $profile $oldMountedGuard "PatientProfileScreen mounted guard"
Assert-Contains $router $oldRouterBlock "AppRouter medical records block"
Assert-Contains $router $prescriptionControllerImport "PrescriptionController import"
Assert-Contains $sessionTest $oldSessionAssertions "Pharmacy session reset assertions"

Write-Ok "All expected source blocks were found"

Write-Step "Prepare corrected files"

$appConfig = @'
import 'package:flutter/foundation.dart';

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

    if (uri == null ||
        !uri.hasAuthority ||
        (!isHttps && !isAllowedLocalHttp)) {
      throw StateError(
        'Remote API mode requires HTTPS. Plain HTTP is allowed only for local debug hosts.',
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

$configTests = @'
import 'package:asaancare/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig.validateValues', () {
    test('mock mode skips remote endpoint validation', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: true,
          apiBaseUrl: '',
          requestTimeoutSeconds: 0,
          allowLocalHttp: false,
        ),
        returnsNormally,
      );
    });

    test('accepts an HTTPS remote endpoint', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'https://api.asaancare.example',
          requestTimeoutSeconds: 20,
          allowLocalHttp: false,
        ),
        returnsNormally,
      );
    });

    test('rejects a public plain HTTP endpoint', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'http://api.asaancare.example',
          requestTimeoutSeconds: 20,
          allowLocalHttp: true,
        ),
        throwsStateError,
      );
    });

    test('allows approved local HTTP hosts when enabled', () {
      for (final host in ['localhost', '127.0.0.1', '10.0.2.2']) {
        expect(
          () => AppConfig.validateValues(
            useMockApi: false,
            apiBaseUrl: 'http://$host:3000',
            requestTimeoutSeconds: 20,
            allowLocalHttp: true,
          ),
          returnsNormally,
        );
      }
    });

    test('rejects local HTTP when the local override is disabled', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'http://localhost:3000',
          requestTimeoutSeconds: 20,
          allowLocalHttp: false,
        ),
        throwsStateError,
      );
    });

    test('rejects an empty remote URL', () {
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

    test('rejects a timeout below the supported range', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'https://api.asaancare.example',
          requestTimeoutSeconds: 4,
          allowLocalHttp: false,
        ),
        throwsStateError,
      );
    });

    test('rejects a timeout above the supported range', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: false,
          apiBaseUrl: 'https://api.asaancare.example',
          requestTimeoutSeconds: 121,
          allowLocalHttp: false,
        ),
        throwsStateError,
      );
    });
  });
}
'@

$workflow = @'
name: Flutter CI

on:
  pull_request:
  push:
    branches:
      - main

concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.head.ref || github.ref_name }}
  cancel-in-progress: true

permissions:
  contents: read

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

$updatedPharmacyController = $pharmacyController.Replace(
    $oldResetBlock,
    $newResetBlock
)
$updatedProfile = $profile.Replace(
    $oldMountedGuard,
    $newMountedGuard
)
$updatedRouter = $router.Replace(
    $oldRouterBlock,
    $newRouterBlock
).Replace(
    $prescriptionControllerImport,
    ""
)
$updatedSessionTest = $sessionTest.Replace(
    $oldSessionAssertions,
    $newSessionAssertions
)

if ($updatedPharmacyController -eq $pharmacyController) {
    throw "PharmacyController replacement produced no change."
}
if ($updatedProfile -eq $profile) {
    throw "PatientProfileScreen replacement produced no change."
}
if ($updatedRouter -eq $router) {
    throw "AppRouter replacement produced no change."
}
if ($updatedSessionTest -eq $sessionTest) {
    throw "Session test replacement produced no change."
}

Write-Step "Write fixes"

Write-Utf8NoBom $appConfigPath $appConfig
Write-Utf8NoBom $configTestPath $configTests
Write-Utf8NoBom $pharmacyControllerPath $updatedPharmacyController
Write-Utf8NoBom $profilePath $updatedProfile
Write-Utf8NoBom $routerPath $updatedRouter
Write-Utf8NoBom $sessionTestPath $updatedSessionTest
Write-Utf8NoBom $workflowPath $workflow

Write-Ok "All confirmed fixes were written"

$dartCommand = Get-Command dart -ErrorAction SilentlyContinue
$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue

if ($null -eq $dartCommand) {
    Write-InfoLine "Dart is not in PATH. Skipping format."
} else {
    Run-Checked "dart format" {
        & dart format lib test
    }
}

if ($null -eq $flutterCommand) {
    Write-InfoLine "Flutter is not in PATH. Skipping analyze, tests, and build."
} else {
    Run-Checked "flutter analyze" {
        & flutter analyze
    }

    Run-Checked "flutter test" {
        & flutter test
    }

    Run-Checked "flutter build web --release" {
        & flutter build web --release
    }
}

Write-Step "Result"

& git status --short
if ($LASTEXITCODE -ne 0) {
    throw "Could not show Git status."
}

Write-Host ""
Write-Host "Patch completed. Nothing was committed or pushed." -ForegroundColor Green
Write-Host "Do not run git add or git commit until the diff is reviewed." -ForegroundColor Yellow
