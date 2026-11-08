# LIÊN HOA ACCOUNTING AI API

NestJS modular-monolith API foundation.

## Local development

```bash
npm install
npm run dev:api
```

Health endpoint: `GET http://localhost:4000/api/v1/health`.

Business modules must resolve the authenticated user and tenant membership server-side. Never trust a client-provided tenant ID as authorization. Financial posting must use the database posting function and pass tenant-isolation and balanced-ledger tests.
