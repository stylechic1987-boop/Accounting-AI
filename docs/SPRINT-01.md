# Sprint 01 — Commercial Foundation

## Goal
Prepare the production codebase without changing or removing the investor demo.

## Work items
- [x] Create isolated branch `commercial-foundation` from the verified demo commit.
- [x] Add npm workspaces and pinned package versions for web and API.
- [x] Create Next.js commercial web dashboard shell.
- [x] Create NestJS API shell with health endpoint.
- [x] Add database migration baseline for tenant, organization, membership, roles and double-entry journal foundation.
- [ ] Complete server-side tenant resolution and automated cross-tenant RLS tests.
- [ ] Add CI checks and confirm green build on the commercial branch.
- [x] Configure environment template; no real credentials committed.
- [x] Provision dedicated Accounting AI Supabase project in Singapore.

## Database verification
- Project: `omndpydrvyonrqhrhddy`
- Status: `ACTIVE_HEALTHY`
- Eight public business tables verified with RLS enabled.
- Journal posting RPC checks tenant role, open period, date range, at least two lines and debit/credit equality.
- Posted and reversed journal records are protected from ordinary mutation.

## Acceptance criteria still open
- User can belong to multiple organizations with explicit active-organization selection.
- Cross-tenant reads and writes fail closed under authenticated test users.
- Automated balanced-journal, immutability and period-lock tests pass.
- CI is green on the commercial branch.

## Product scope
The pilot test matrix will cover both enterprises and household businesses. The two accounting regimes remain separate configuration/rule packs and require specialist review before production tax use.

## Decisions still required
- Production domain and hosting provider.
- Accounting specialists to validate the applicable enterprise and household-business rule packs.
- Provider contracts and sandbox credentials for e-invoice, digital signature, T-VAN and banking integrations.
