# LIÊN HOA ACCOUNTING AI

Commercial foundation for a Vietnamese accounting, finance and tax platform.

## Repository layout
- `index.html`: original investor demo; intentionally preserved.
- `apps/web`: Next.js commercial web application.
- `apps/api`: NestJS modular-monolith API.
- `supabase/migrations`: versioned database schema and security policies.
- `docs`: architecture and sprint decisions.

## Local development
Requirements: Node.js 22+.

```bash
npm install
npm run dev:web
```

In another terminal run `npm run dev:api`.

Copy `.env.example` to a local environment file. Fill in the public Supabase URL and anon key from the project dashboard. Never commit service-role keys or other secrets.

## Supabase
Project ref: `omndpydrvyonrqhrhddy` (Singapore). Apply future migrations in order and verify RLS before enabling features.

## Safety boundary
This repository is not yet a production accounting or tax filing system. Do not use it for statutory books, tax declarations, invoice issuance, signatures or submissions until accounting/tax acceptance, tenant-isolation tests, security review and partner approvals are complete.
