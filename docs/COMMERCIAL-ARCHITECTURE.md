# LIÊN HOA ACCOUNTING AI — Commercial Architecture

## Product mandate
A Vietnamese accounting, finance and tax workflow platform for enterprises and household businesses. Commercial model: multi-tenant SaaS plus partner-operated white-label. Liên Hoa owns the core source, product architecture, brand and domain rules.

## Repository boundaries
- This repository is the independent Accounting AI product. It must not share accounting tables with Liên Hoa CRM, TS24H, or other projects.
- CRM may later exchange approved customer/lead metadata through versioned APIs. CRM must never write directly to the accounting ledger.
- Keep the existing root `index.html` investor demo intact. Commercial implementation is developed on `commercial-foundation`.

## Target architecture
- Web client: Next.js + TypeScript.
- Mobile client: React Native + Expo (later phase).
- API: NestJS modular monolith; versioned REST API and OpenAPI contract.
- Data: PostgreSQL. Supabase may provide managed Postgres, Auth and Storage; business rules remain portable.
- Async work: queue/worker for imports, OCR, reconciliation and integration retries.
- Files: private object storage with tenant-scoped access.
- Observability: structured logs, metrics, tracing, error reporting and audit events.

## Core bounded contexts
1. Identity & tenancy: organizations, tenants, memberships, roles, invitations and entitlements.
2. Accounting: chart of accounts, fiscal periods, journals, journal lines, posting, reversals, ledger and trial balance.
3. Receivables & payables: customers, suppliers, invoices, receipts, payments and allocations.
4. Cash & banking: cashbooks, bank accounts, statement imports and reconciliation.
5. Inventory: warehouses, stock movements, costing and stock ledger.
6. Tax & e-invoice: tax profiles, tax periods, draft returns, partner adapters, receipts and status tracking.
7. Integrations: provider credentials, sandbox/production environments, idempotency, retries, redacted request logs and reconciliation.
8. AI assistance: OCR and recommendations only; user approval required before posting or external submission.
9. SaaS & white-label: plans, subscriptions, usage, partner tenants, branding and domain configuration.

## Accounting invariants
- Double-entry: every posted journal balances; total debits equal total credits.
- Drafts may be edited. Posted journals are immutable; corrections use reversal and replacement entries.
- Posting and all journal lines commit atomically in one database transaction.
- Closed periods reject ordinary posting. Reopening requires an authorized workflow and audit record.
- Every business record is tenant-scoped. Tenant identity is derived from a verified membership, never trusted from an arbitrary client-supplied tenant_id.
- Monetary values use fixed-precision decimal types, never floating-point arithmetic.
- Persist currency, exchange rate, source document, posting user, timestamps and audit metadata.

## Security baseline
- RLS enabled on every exposed table; least-privilege grants are explicit.
- Authorization uses server-validated membership/role data, not user-editable JWT user_metadata.
- No service-role or secret key in browser/mobile bundles.
- MFA for privileged roles; audit logs for access-sensitive and financial actions.
- Tenant-isolation tests are release blockers.
- Private storage buckets and signed, short-lived access URLs.
- Backups, restore drills, dependency pinning and secret rotation.

## Tax and compliance boundary
- Separate accounting rule packs for enterprises and household businesses; do not force one ledger template onto both.
- Validate applicable Vietnamese accounting and tax rules with qualified specialists before production release.
- Tax filing, e-invoice issuance, digital signatures, social insurance and bank connectivity are provider adapters. Do not claim direct government connectivity without an approved technical/legal path and contract.
- AI never autonomously posts journals, issues invoices, signs or submits tax declarations.

## Delivery sequence
1. Foundation: repository structure, CI, domain model, tenancy and identity.
2. Accounting core: chart of accounts, fiscal periods, journal workflow, posting engine and ledger.
3. Operations: cash, bank, sales, purchases, receivables/payables and inventory.
4. Reports and tax workspaces.
5. Partner integrations and e-invoice.
6. AI assistance and mobile.
7. SaaS billing, partner console and white-label.
8. Security, accounting/tax acceptance, pilot and commercial launch.

## Non-goals for first release
- Microservices, blockchain, automatic tax submission, autonomous AI bookkeeping, or direct integrations without provider approval.
