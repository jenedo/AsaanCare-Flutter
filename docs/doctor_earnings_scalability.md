# Doctor earnings production contract

The doctor earnings UI is designed for paged data and lazy rendering, but
50,000 concurrent users is a backend and infrastructure capacity target. It
must be proven with load tests against the production-like API, database,
cache, queue, and payout provider.

## API surface

### `GET /v1/doctor/earnings/summary`

Query parameters:

- `period`: `month`, `quarter`, or `year`
- `timezone`: IANA timezone used to calculate period boundaries

Response fields:

- `currency`: ISO 4217 code, for example `PKR`
- `grossAmount`, `netAmount`, `pendingAmount`, `withdrawnAmount`,
  `platformFee`: integer minor units
- `completedConsultations`, `growthPercent`
- `trend`: server-aggregated points capped to the requested period
- `breakdown`: consultation category totals and percentages
- `generatedAt`: ISO 8601 timestamp

The authenticated doctor identity must come from the verified session, never
from a client-provided doctor ID.

### `GET /v1/doctor/earnings/transactions`

Query parameters:

- `cursor`: opaque continuation cursor
- `limit`: default `25`, maximum `100`
- `status`: optional `completed` or `pending`
- `period`: optional period filter

The response returns `items`, `nextCursor`, and `hasMore`. Cursor pagination is
required so latency does not grow with ledger size. The mobile client should
retain only a bounded number of pages and request the next page near the end
of the list.

### `POST /v1/doctor/payouts`

This route is intentionally not active in the demo UI. A production version
must require step-up verification, an `Idempotency-Key`, server-side balance
validation, and an immutable ledger transaction. Return `202 Accepted` while
the payout is processed asynchronously. Reusing the same idempotency key must
return the original result and must never create a second payout.

## 50k-concurrency architecture

- Run stateless API instances behind a load balancer with horizontal
  autoscaling and bounded request queues.
- Cache summary responses per doctor and period for 30-60 seconds; invalidate
  on new ledger events.
- Store money as integer minor units in an append-only double-entry ledger.
- Use indexed cursor columns such as `(doctor_id, created_at DESC, id DESC)`.
- Use database connection pooling; cap application connections below the
  database limit and add read replicas for summary/history reads.
- Move payout-provider calls to a durable queue with retry, dead-letter, and
  reconciliation workers.
- Apply authenticated user and IP rate limits. Return `429` with `Retry-After`
  rather than allowing a traffic spike to exhaust the database.
- Encrypt traffic and sensitive payout data, redact logs, and audit every
  balance-changing operation.

## Required load-test gate

Test in a production-like environment with realistic account and ledger
cardinality. Ramp through 1k, 5k, 10k, 25k, and 50k concurrent sessions instead
of jumping directly to peak load.

Release only when all of these hold for the planned peak window:

- summary and first transaction page: p95 under 300 ms, p99 under 750 ms
- server error rate below 0.5%
- no database connection-pool exhaustion
- no duplicate ledger or payout records under retries
- queue lag returns to normal after the peak
- autoscaling stabilizes without retry storms

Flutter widget tests validate client rendering and interaction. They do not
replace this distributed load test.
