# Sprint 01 — Commercial Foundation

## Goal
Prepare the commercial codebase without changing or removing the investor demo.

## Work items
- [x] Create isolated branch `commercial-foundation`; preserve demo branch `main`.
- [x] Add npm workspaces and pinned package versions for web and API.
- [x] Create Next.js commercial web dashboard shell.
- [x] Create NestJS API shell with health endpoint.
- [x] Add database migration baseline for tenant, organization, membership, roles and double-entry journal foundation.
- [x] Add Supabase SSR authentication pages, email confirmation callback and session refresh proxy.
- [x] Add first-time workspace onboarding for both enterprise and household business.
- [x] Add atomic database function to create organization, owner membership, accounting profile and current fiscal period.
- [x] Revoke anonymous execution on privileged functions; verified anonymous cannot execute the tenant bootstrap or ledger RPCs.
- [ ] Confirm CI green after the authentication and onboarding changes.
- [ ] Complete automated cross-tenant RLS tests using separate authenticated test users.
- [ ] Add password recovery, MFA and organization switching.
- [x] Configure environment template; no real credentials committed.
- [x] Provision dedicated Accounting AI Supabase project in Singapore.

## Database verification
- Project: `omndpydrvyonrqhrhddy`
- Status: `ACTIVE_HEALTHY`
- Eight initial public business tables have RLS enabled.
- Tenant bootstrap RPC is executable by authenticated users only; it derives owner identity from `auth.uid()`.
- Journal posting RPC checks tenant role, open period, date range, at least two lines and debit/credit equality.
- Posted and reversed journal records are protected from ordinary mutation.

## Acceptance criteria still open
- Cross-tenant reads and writes fail closed under authenticated test users.
- Automated balanced-journal, immutability and period-lock tests pass.
- CI is green on the latest commercial branch commit.
- Sign-up, email confirmation, sign-in and tenant onboarding pass an end-to-end test with a real test account.

## Product scope
The pilot test matrix covers both enterprises and household businesses. The two accounting regimes remain separate configuration/rule packs and require specialist review before production tax use.

## Decisions still required
- Production domain and hosting provider.
- Accounting specialists to validate the applicable enterprise and household-business rule packs.
- Provider contracts and sandbox credentials for e-invoice, digital signature, T-VAN and banking integrations.
