$ErrorActionPreference = 'Stop'

if (-not (Test-Path 'pubspec.yaml') -or -not (Test-Path 'lib')) {
    throw 'Run this script from the root of D:\VP\Project\Health--.'
}

$bundleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceRoot = Join-Path $bundleRoot 'new_files'

function Copy-BundledFile {
    param([Parameter(Mandatory)][string]$RelativePath)

    $source = Join-Path $sourceRoot $RelativePath
    $target = Join-Path (Get-Location) $RelativePath
    $targetDirectory = Split-Path -Parent $target
    New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
    Copy-Item $source $target -Force
}

function Replace-Exact {
    param(
        [Parameter(Mandatory)][string]$RelativePath,
        [Parameter(Mandatory)][string]$Old,
        [Parameter(Mandatory)][string]$New
    )

    $path = Join-Path (Get-Location) $RelativePath
    $content = [System.IO.File]::ReadAllText($path).Replace("`r`n", "`n")
    if (-not $content.Contains($Old)) {
        throw "Expected code was not found in $RelativePath. Stop: no partial unsafe replacement was made for this step."
    }

    $updated = $content.Replace($Old, $New)
    [System.IO.File]::WriteAllText(
        $path,
        $updated,
        [System.Text.UTF8Encoding]::new($false)
    )
}

Copy-BundledFile 'lib\core\widgets\app_bottom_nav_bar.dart'
Copy-BundledFile 'lib\features\doctors\domain\repositories\doctor_repository.dart'
Copy-BundledFile 'lib\features\doctors\domain\usecases\get_doctors.dart'
Copy-BundledFile 'lib\features\doctors\data\datasources\doctor_mock_data_source.dart'
Copy-BundledFile 'lib\features\doctors\data\repositories\doctor_repository_impl.dart'
Copy-BundledFile 'lib\features\doctors\presentation\controllers\find_doctors_controller.dart'
Copy-BundledFile 'lib\features\doctors\presentation\screens\find_doctors_screen.dart'
Copy-BundledFile 'test\features\doctors\presentation\controllers\find_doctors_controller_test.dart'

Replace-Exact `
    'lib\core\routes\app_routes.dart' `
    "  static const String doctorDetail = '/doctor-detail';" `
    "  static const String findDoctors = '/find-doctors';`n  static const String doctorDetail = '/doctor-detail';"

Replace-Exact `
    'lib\core\routes\app_router.dart' `
    "import '../../features/doctors/presentation/controllers/doctor_detail_controller.dart';`nimport '../../features/doctors/presentation/screens/doctor_detail_screen.dart';" `
    "import '../../features/doctors/presentation/controllers/doctor_detail_controller.dart';`nimport '../../features/doctors/presentation/controllers/find_doctors_controller.dart';`nimport '../../features/doctors/presentation/screens/doctor_detail_screen.dart';`nimport '../../features/doctors/presentation/screens/find_doctors_screen.dart';"

Replace-Exact `
    'lib\core\routes\app_router.dart' `
    '    AppRoutes.doctorDetail,' `
    "    AppRoutes.findDoctors,`n    AppRoutes.doctorDetail,"

$findDoctorsRoute = @'
      case AppRoutes.findDoctors:
        return _smoothRoute(
          settings: settings,
          child: FindDoctorsScreen(
            controller: sl<FindDoctorsController>(),
          ),
        );

'@

Replace-Exact `
    'lib\core\routes\app_router.dart' `
    '      case AppRoutes.doctorDetail:' `
    ($findDoctorsRoute + '      case AppRoutes.doctorDetail:')

Replace-Exact `
    'lib\core\di\service_locator.dart' `
    "import '../../features/doctors/domain/usecases/get_doctor_detail.dart';`nimport '../../features/doctors/presentation/controllers/doctor_detail_controller.dart';" `
    "import '../../features/doctors/domain/usecases/get_doctor_detail.dart';`nimport '../../features/doctors/domain/usecases/get_doctors.dart';`nimport '../../features/doctors/presentation/controllers/doctor_detail_controller.dart';`nimport '../../features/doctors/presentation/controllers/find_doctors_controller.dart';"

$doctorRegistrations = @'
  sl.registerLazySingleton<GetDoctors>(
    () => GetDoctors(sl<DoctorRepository>()),
  );
  sl.registerFactory<FindDoctorsController>(
    () => FindDoctorsController(getDoctors: sl<GetDoctors>()),
  );
'@

Replace-Exact `
    'lib\core\di\service_locator.dart' `
    "  sl.registerLazySingleton<GetDoctorDetail>(`n    () => GetDoctorDetail(sl<DoctorRepository>()),`n  );" `
    ($doctorRegistrations + "  sl.registerLazySingleton<GetDoctorDetail>(`n    () => GetDoctorDetail(sl<DoctorRepository>()),`n  );")

Replace-Exact `
    'lib\features\patient\presentation\screens\patient_home_screen.dart' `
    "      case 1:`n        _openDoctor('doctor_ali');`n        return;" `
    "      case 1:`n        Navigator.of(context).pushNamed(AppRoutes.findDoctors);`n        return;"

Replace-Exact `
    'lib\features\patient\presentation\screens\patient_home_screen.dart' `
    "onTap: () => _showComingSoon('Search')," `
    "onTap: () => Navigator.of(context).pushNamed(AppRoutes.findDoctors),"

Replace-Exact `
    'lib\features\patient\presentation\screens\patient_home_screen.dart' `
    "onTap: () => _showComingSoon('Featured doctors')," `
    "onTap: () => Navigator.of(context).pushNamed(AppRoutes.findDoctors),"

Replace-Exact `
    'lib\features\patient\presentation\screens\patient_home_screen.dart' `
    "                _ConsultBanner(`n                  doctorAsset: _bannerDoctor,`n                  onTap: () => _openDoctor('doctor_ali'),`n                )," `
    "                _ConsultBanner(`n                  doctorAsset: _bannerDoctor,`n                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.findDoctors),`n                ),"

Replace-Exact `
    'lib\features\patient\presentation\screens\patient_home_screen.dart' `
    "                        PatientHomeCard(`n                          icon: Icons.calendar_month_outlined,`n                          title: 'Book\nAppointment',`n                          iconColor: const Color(0xFF2563EB),`n                          onTap: () => _openDoctor('doctor_ali'),`n                        )," `
    "                        PatientHomeCard(`n                          icon: Icons.calendar_month_outlined,`n                          title: 'Book\nAppointment',`n                          iconColor: const Color(0xFF2563EB),`n                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.findDoctors),`n                        ),"

dart format lib test
flutter analyze
flutter test test/features/doctors/presentation/controllers/find_doctors_controller_test.dart

Write-Host ''
Write-Host 'Find Doctors is installed and validated.' -ForegroundColor Green
Write-Host 'Review changes with: git diff'
