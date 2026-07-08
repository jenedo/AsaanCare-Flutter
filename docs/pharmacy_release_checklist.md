# Pharmacy Release Checklist

## Automated gates

- `flutter analyze`
- `flutter test test/features/pharmacy`
- 100 unique catalog SKUs
- valid prices, stock and product codes
- search by brand, generic and category
- cart quantity capped by stock and per-item limit
- checkout validates address, stock, prescription and wallet balance
- mobile smoke tests at 320, 360, 393 and 430 pixels

## Manual flow

1. Open Pharmacy.
2. Search for Panadol.
3. Filter by category and in-stock status.
4. Open medicine details.
5. Add multiple quantities.
6. Confirm cart totals.
7. Change delivery address and pharmacy.
8. Select COD, Easypaisa, JazzCash, card and wallet.
9. Confirm invalid wallet state is blocked when total exceeds demo balance.
10. Place a demo order.
11. Advance tracking until delivered.
12. Confirm Records opens from Upload Prescription.

## Production blockers

- Real auth provider and verified JWT
- NestJS pharmacy and order APIs
- PostgreSQL catalog, stock and order tables
- Private prescription storage
- licensed product images and CDN
- payment-provider credentials and verified webhooks
- pharmacy inventory integration
- notification provider
- audit logging and monitoring

The Flutter demo must never contain payment secrets or trust client-calculated price, stock or payment success.
