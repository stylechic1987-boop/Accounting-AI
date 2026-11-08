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

Copy `.env.example` to `apps/web/.env.local`. Set:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`
- `NEXT_PUBLIC_SITE_URL` (for local development, `http://localhost:3000`)

Use the project's publishable key, not a secret/service-role key, in the web app. Never commit credentials.

## Authentication setup
- Open `/signup` to register and confirm the email.
- Configure Supabase Auth Site URL and Redirect URLs to include the deployed app URL and `/auth/callback`.
- After confirmation, users are directed to `/onboarding` to create an enterprise or household-business workspace.
- `/workspace` lists organizations visible to the signed-in user.
- Sessions use Supabase SSR cookies and the Next.js Proxy refresh flow.

## Supabase
Project ref: `omndpydrvyonrqhrhddy` (Singapore). Apply future migrations in order and verify RLS before enabling features.

## Safety boundary
This repository is not yet a production accounting or tax filing system. Do not use it for statutory books, tax declarations, invoice issuance, signatures or submissions until accounting/tax acceptance, tenant-isolation tests, security review and partner approvals are complete.
