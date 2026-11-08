# Sprint 01 — Commercial Foundation

## Goal
Prepare the production codebase without changing or removing the investor demo.

## Work items
- [x] Create isolated Git branch `commercial-foundation` from the verified demo commit.
- [ ] Add monorepo workspace and pinned toolchain.
- [ ] Create Next.js web app shell with login and organization selection screens.
- [ ] Create NestJS API shell with health endpoint and OpenAPI.
- [ ] Add database migration baseline for tenant, organization, membership and role model.
- [ ] Define server-side tenant resolution and RLS policy tests.
- [ ] Add CI checks: formatting, lint, typecheck and tests.
- [ ] Configure environment templates; never commit secrets.
- [ ] Provision a dedicated Accounting AI database project after organization and cost confirmation.

## Acceptance criteria
- Demo at the root remains unchanged.
- Commercial app runs separately from the demo.
- A user can belong to multiple organizations, with explicit active-organization selection.
- Cross-tenant reads and writes fail closed.
- No financial posting feature is released until balanced-journal and immutability tests pass.
- CI is green on the commercial branch.

## Decisions still required before production provisioning
- Confirm the Supabase organization and the quoted recurring project cost.
- Confirm initial accounting pilot: enterprise, household business, or both. Product scope remains both; pilot order determines test cases and acceptance.
- Confirm production domain and hosting provider.
