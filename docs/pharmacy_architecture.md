# AsaanCare Pharmacy Architecture

## Implementation rule

The supplied diagram is the target architecture. The current backend should begin as a feature-based NestJS modular monolith, not separately deployed microservices.

```text
Flutter Screens
  -> PharmacyController
    -> Use Cases
      -> PharmacyRepository
        -> MockDataSource now
        -> RemoteDataSource later
          -> NestJS API
            -> PostgreSQL / Redis / private object storage
```

## Production modules

- Auth
- Users
- Doctors
- Appointments
- Consultations
- Prescriptions
- Pharmacy catalog
- Cart and orders
- Payments
- Files
- Notifications
- Audit logs

Extract a module into a microservice only when independent scaling, ownership or reliability makes it necessary.

## Pharmacy API contract

- GET /v1/pharmacy/medicines
- GET /v1/pharmacy/medicines/:id
- GET /v1/pharmacy/categories
- GET /v1/pharmacy/nearby
- POST /v1/pharmacy/cart/validate
- POST /v1/pharmacy/orders
- GET /v1/pharmacy/orders/:id
- POST /v1/prescriptions
- POST /v1/payments/intents
- POST /v1/payments/webhooks/:provider

## Security

- Patient identity comes from the verified token.
- Prices and stock are revalidated by the backend.
- Prescription files remain private and use signed URLs.
- Payment success comes only from a verified provider webhook.
- Prescription-required products need verification before fulfilment.
- No secret is stored in Flutter.
- Current payment and tracking are explicit local demos.