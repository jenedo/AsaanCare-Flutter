param(
  [string]$RepoPath = "D:\VP\Project\Health--"
)

$ErrorActionPreference = "Stop"

function Replace-Required {
  param(
    [string]$Path,
    [string]$Old,
    [string]$New
  )

  if (-not (Test-Path $Path)) {
    throw "Missing file: $Path"
  }

  $content = Get-Content -Raw -Encoding UTF8 $Path
  if (-not $content.Contains($Old)) {
    throw "Expected code block not found in: $Path"
  }

  $updated = $content.Replace($Old, $New)
  Set-Content -Path $Path -Value $updated -Encoding UTF8 -NoNewline
  Write-Host "Updated: $Path" -ForegroundColor Green
}

Set-Location $RepoPath

$branch = git branch --show-current
if ($branch -ne "pharmacy-consolidated-fix-20260708") {
  throw "Wrong branch: $branch. Switch to pharmacy-consolidated-fix-20260708 first."
}

if (-not (git diff --quiet)) {
  throw "Working tree has uncommitted changes. Commit or stash them before running this patch."
}

# 1) Harden AppConfig and expose pure validation for tests.
$appConfigPath = Join-Path $RepoPath "lib\core\config\app_config.dart"
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
Set-Content -Path $appConfigPath -Value $appConfig -Encoding UTF8 -NoNewline
Write-Host "Updated: $appConfigPath" -ForegroundColor Green

# 2) Reset all user-scoped pharmacy state on logout.
$pharmacyController = Join-Path $RepoPath "lib\features\pharmacy\presentation\controllers\pharmacy_controller.dart"
Replace-Required `
  -Path $pharmacyController `
  -Old @'
    if (resetSession) {
      _favoriteIds.clear();
      _activeOrder = null;
      _paymentMethod = PharmacyPaymentMethod.cashOnDelivery;
'@ `
  -New @'
    if (resetSession) {
      _favoriteIds.clear();
      _activeOrder = null;
      _recentPrescription = null;
      _status = PharmacyStatus.initial;
      _paymentMethod = PharmacyPaymentMethod.cashOnDelivery;
'@

# 3) Fix context/setState use after await.
$profileScreen = Join-Path $RepoPath "lib\features\patient\presentation\screens\patient_profile_screen.dart"
Replace-Required `
  -Path $profileScreen `
  -Old @'
    if (selected == null || selected == _language) return;
    setState(() => _language = selected);
'@ `
  -New @'
    if (!mounted || selected == null || selected == _language) return;
    setState(() => _language = selected);
'@

# 4) Remove misleading patient-id fallback and fail safely.
$appRouter = Join-Path $RepoPath "lib\core\routes\app_router.dart"
Replace-Required `
  -Path $appRouter `
  -Old @'
      case AppRoutes.medicalRecords:
        final patientId =
            authController.currentUser?.id ??
            PrescriptionController.mockPatientId;

        return _smoothRoute(
'@ `
  -New @'
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

# Remove now-unused PrescriptionController import if it is only used for the fallback.
$routerContent = Get-Content -Raw -Encoding UTF8 $appRouter
$routerContent = $routerContent.Replace(
  "import '../../features/prescriptions/presentation/controllers/prescription_controller.dart';`r`n",
  ""
)
$routerContent = $routerContent.Replace(
  "import '../../features/prescriptions/presentation/controllers/prescription_controller.dart';`n",
  ""
)
Set-Content -Path $appRouter -Value $routerContent -Encoding UTF8 -NoNewline

# 5) Capture and log expected auth errors too.
$authController = Join-Path $RepoPath "lib\features\auth\presentation\controllers\auth_controller.dart"
Replace-Required `
  -Path $authController `
  -Old @'
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
'@ `
  -New @'
    } on AuthException catch (error, stackTrace) {
      AppLogger.error('AuthController.login', error, stackTrace);
      _errorMessage = error.message;
      return false;
'@

Replace-Required `
  -Path $authController `
  -Old @'
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
'@ `
  -New @'
    } on AuthException catch (error, stackTrace) {
      AppLogger.error('AuthController.registerPatient', error, stackTrace);
      _errorMessage = error.message;
      return false;
'@

# 6) Log unknown backend roles before safe fallback.
$authUserModel = Join-Path $RepoPath "lib\features\auth\data\models\auth_user_model.dart"
$authModelContent = Get-Content -Raw -Encoding UTF8 $authUserModel
if (-not $authModelContent.Contains("import '../../../../core/logging/app_logger.dart';")) {
  $authModelContent = $authModelContent.Replace(
    "import '../../domain/entities/auth_user.dart';",
    "import '../../../../core/logging/app_logger.dart';`r`nimport '../../domain/entities/auth_user.dart';"
  )
}
$oldRole = @'
    return UserRole.values.firstWhere(
      (role) => role.name == normalized,
      orElse: () => UserRole.patient,
    );
'@
$newRole = @'
    for (final role in UserRole.values) {
      if (role.name == normalized) return role;
    }

    AppLogger.error(
      'AuthUserModel._roleFromString',
      FormatException('Unknown user role: $value'),
      StackTrace.current,
    );
    return UserRole.patient;
'@
if (-not $authModelContent.Contains($oldRole)) {
  throw "Expected role parsing block not found in: $authUserModel"
}
$authModelContent = $authModelContent.Replace($oldRole, $newRole)
Set-Content -Path $authUserModel -Value $authModelContent -Encoding UTF8 -NoNewline
Write-Host "Updated: $authUserModel" -ForegroundColor Green

# 7) De-duplicate CI and harden checkout credentials.
$workflowPath = Join-Path $RepoPath ".github\workflows\flutter_ci.yml"
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
Set-Content -Path $workflowPath -Value $workflow -Encoding UTF8 -NoNewline
Write-Host "Updated: $workflowPath" -ForegroundColor Green

# 8) Add configuration tests.
$configTestPath = Join-Path $RepoPath "test\core\config\app_config_test.dart"
New-Item -ItemType Directory -Force -Path (Split-Path $configTestPath) | Out-Null
$configTest = @'
import 'package:asaancare/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig.validateValues', () {
    test('mock mode skips remote endpoint validation', () {
      expect(
        () => AppConfig.validateValues(
          useMockApi: true,
          apiBaseUrl: '',
          requestTimeoutSeconds: 20,
          allowLocalHttp: false,
        ),
        returnsNormally,
      );
    });

    test('accepts HTTPS remote endpoint', () {
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

    test('rejects public plain HTTP endpoint', () {
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

    test('allows local HTTP only when explicitly enabled', () {
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

    test('rejects local HTTP when local override is disabled', () {
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

    test('rejects timeout outside supported range', () {
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
  });
}
'@
Set-Content -Path $configTestPath -Value $configTest -Encoding UTF8 -NoNewline
Write-Host "Created: $configTestPath" -ForegroundColor Green

# 9) Strengthen pharmacy session reset test.
$sessionTest = Join-Path $RepoPath "test\features\pharmacy\pharmacy_session_reset_test.dart"
Replace-Required `
  -Path $sessionTest `
  -Old @'
      expect(controller.activeOrder, isNull);
      expect(controller.errorMessage, isNull);
'@ `
  -New @'
      expect(controller.activeOrder, isNull);
      expect(controller.recentPrescription, isNull);
      expect(controller.status, PharmacyStatus.initial);
      expect(controller.errorMessage, isNull);
'@

Write-Host "`nFormatting..." -ForegroundColor Cyan
dart format lib test

Write-Host "`nStatic analysis..." -ForegroundColor Cyan
flutter analyze

Write-Host "`nTests..." -ForegroundColor Cyan
flutter test

Write-Host "`nWeb build..." -ForegroundColor Cyan
flutter build web --release

Write-Host "`nPatch complete." -ForegroundColor Green
git status --short
Write-Host "`nReview the diff, then commit with:" -ForegroundColor Yellow
Write-Host 'git add .'
Write-Host 'git commit -m "fix: harden auth pharmacy config and CI"'
Write-Host 'git push origin pharmacy-consolidated-fix-20260708'
