# AsaanCare API and Auth Contract

## Current mode

The Flutter app runs with mock data unless explicitly launched with:

```powershell
flutter run `
  --dart-define=USE_MOCK_API=false `
  --dart-define=API_BASE_URL=https://api.example.com
```

No API secret belongs in Flutter. `API_BASE_URL` is configuration, not a secret.

## Required auth endpoints

### POST `/v1/auth/register`

Request:

```json
{
  "fullName": "Sumiya Ibrahim",
  "emailOrPhone": "sumiya@example.com",
  "password": "example-password",
  "role": "patient"
}
```

Response must contain a user object at `user`, `data.user`, or `data`.

### POST `/v1/auth/login`

Request:

```json
{
  "emailOrPhone": "sumiya@example.com",
  "password": "example-password"
}
```

Response:

```json
{
  "accessToken": "short-lived-token",
  "user": {
    "id": "patient-id",
    "fullName": "Sumiya Ibrahim",
    "emailOrPhone": "sumiya@example.com",
    "role": "patient"
  }
}
```

### GET `/v1/auth/me`

Header:

```text
Authorization: Bearer <accessToken>
```

### POST `/v1/auth/logout`

Header:

```text
Authorization: Bearer <accessToken>
```

## Planned module endpoints

- `/v1/doctors`
- `/v1/appointments`
- `/v1/prescriptions`
- `/v1/medical-records`
- `/v1/pharmacy/medicines`
- `/v1/pharmacy/orders`
- `/v1/notifications`
- `/v1/patients/me`
- `/v1/health/readings`
- `/v1/payments/intents`

## Production requirements

- Backend must derive patient identity from the verified token, never from an untrusted request body.
- Use short-lived access tokens and a verified refresh-session design.
- Flutter web should prefer a backend-managed secure session strategy; do not put long-lived secrets in source code or local storage.
- Server must validate prices, inventory, appointment ownership, file ownership, and payment webhook signatures.
- Medical files must use private storage and short-lived signed access.
- Add rate limiting, audit logs, request ids, monitoring, and centralized error handling on the backend.