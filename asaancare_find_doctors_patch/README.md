# AsaanCare Find Doctors implementation

This patch targets `Fareed556/Health--` on the existing `fix/coderabbit-review` branch.

It adds a layered Find Doctors feature with 25 doctors, search, specialty filters,
sorting, responsive doctor cards, date/slot selection, doctor-detail navigation,
and replaces the footer `Consult` tab with `Find Doctor`.

Apply from the repository root:

```powershell
git switch fix/coderabbit-review
git pull --ff-only
git apply --check asaancare_find_doctors.patch
git apply asaancare_find_doctors.patch
dart format lib test
flutter analyze
flutter test
```

