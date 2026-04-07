# Bear River Conference Application

`bearriver2` is a Ruby on Rails application used to run the Bear River Writers' Conference registration flow end-to-end. It supports applicant sign-up, application submission, conference configuration, payment processing callbacks, and administrative operations through ActiveAdmin.

## What This App Does

- Accepts user registrations and conference applications.
- Stores annual conference configuration (`ApplicationSetting`) and derives current conference year behavior from the active setting.
- Supports lodging and partner registration selections that feed cost and balance calculations.
- Integrates with a hosted payment gateway flow and records payment receipts.
- Provides admin management via ActiveAdmin for conference operations.
- Sends transactional emails for application events and balance due messaging.

## Tech Stack

- Ruby `3.4.9`
- Rails `7.2.2`
- PostgreSQL
- Hotwire (`turbo-rails`, `stimulus-rails`)
- ActiveAdmin
- Devise authentication (users + admin users)
- RSpec + FactoryBot
- RuboCop (Rails profile)
- Front-end bundling:
  - `jsbundling-rails` with `esbuild`
  - `cssbundling-rails` with `sass` + `postcss`

## Core Domain Concepts

- `User`: conference applicant account (Devise auth).
- `Application`: conference submission associated to a user and scoped by `conf_year`.
- `ApplicationSetting`: annual/admin-configurable conference settings; exactly one record should be active.
- `Payment`: user payment records (gateway and manual entries), tied to `conf_year`.
- Supporting lookup/config models: `Workshop`, `Lodging`, `PartnerRegistration`, `Gender`.

## High-Level Request Flow

1. User signs up/logs in.
2. User submits `Application`.
3. App computes costs from selected lodging/partner options and optional subscription.
4. User is redirected to payment gateway for payment.
5. Gateway callback posts receipt data to `payment_receipt`, where it is validated/recorded.
6. User/admin can review payments and balances.

## Prerequisites

Install the following locally:

- Ruby `3.4.9`
- Bundler
- Node.js + Yarn
- PostgreSQL (running locally)
- Redis (used by Action Cable in development)

## Local Development Setup

### 1) Install dependencies

```bash
bundle install
yarn install
```

### 2) Configure credentials and environment

This app expects encrypted Rails credentials and some environment variables.

- Ensure `config/master.key` is available locally (or provide `RAILS_MASTER_KEY`).
- Set required environment variables where applicable:
  - `DATABASE_URL` (staging/production)
  - `REDIS_URL` (production Action Cable; optional in local if using defaults)
  - `SENDGRID_API_KEY` (production mail delivery)

The payment gateway integration reads these Rails credentials keys:

- `NELNET_SERVICE.DEVELOPMENT_KEY`
- `NELNET_SERVICE.DEVELOPMENT_URL`
- `NELNET_SERVICE.PRODUCTION_KEY`
- `NELNET_SERVICE.PRODUCTION_URL`
- `NELNET_SERVICE.SERVICE_SELECTOR` (for QA/dev selection behavior)

Devise mailer sender is read from:

- `devise.mailer_sender`

### 3) Setup database

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

### 4) Start the app

Preferred (runs Rails + JS + CSS watchers via `foreman`):

```bash
bin/dev
```

This starts:

- Rails server (`web`)
- JS bundler watch (`js`)
- CSS build/watch (`css`)

App will be available at [http://localhost:3000](http://localhost:3000).

## Authentication and Admin

- User auth routes are provided by Devise (`/users/...`).
- Admin interface is mounted with ActiveAdmin.
- Seed data creates a development-only admin user:
  - Email: `admin@example.com`
  - Password: `password`

Change or remove this immediately outside local development.

## Key Routes

- Root: `/`
- Applications: `/applications`
- Payments:
  - `/payments`
  - `/make_payment`
  - `/payment_receipt` (gateway callback endpoint)
- Static pages:
  - `/about`
  - `/contact`
  - `/privacy`
  - `/terms_of_service`

## Testing

Run the full test suite:

```bash
bundle exec rspec
```

Run a focused spec file:

```bash
bundle exec rspec spec/requests/payments_spec.rb
```

## Linting

```bash
bundle exec rubocop
```

## Email Behavior by Environment

- `development` and `staging` use `letter_opener_web` tooling for local/staging preview.
- `production` uses SMTP (SendGrid), configured in `config/environments/production.rb`.

In development/staging, preview mail at:

- `/letter_opener`

## Deployment Notes

- `staging` and `production` use `DATABASE_URL`.
- `production` enforces SSL (`config.force_ssl = true`).
- Ensure credentials and environment variables are set before boot.
- Precompile assets for production deploys:

```bash
bin/rails assets:precompile
```

## Operational Guidance

- Keep exactly one `ApplicationSetting` record active to avoid ambiguous "current conference" behavior.
- Payment totals are stored as strings representing cents in parts of the flow; preserve conversion logic when modifying payment code.
- Gateway callback validation is security-sensitive; treat changes to receipt verification paths as high risk and cover with request/service tests.

## Useful Commands

```bash
# Start all local services
bin/dev

# Prepare DB from scratch
bin/rails db:drop db:create db:migrate db:seed

# Run tests and lints
bundle exec rspec
bundle exec rubocop
```

## Troubleshooting

- **`ActiveSupport::MessageEncryptor::InvalidMessage`**  
  Missing/incorrect `master.key` for encrypted credentials.

- **Database connection errors**  
  Verify local PostgreSQL is running and database/user access is configured.

- **Asset build issues**  
  Re-run `yarn install` and start via `bin/dev` so JS/CSS watchers are active.

- **Payment redirect issues in local**  
  Confirm `NELNET_SERVICE` credential values and environment selection logic.

## Contributing

1. Create a feature branch from `staging`.
2. Add/adjust tests for behavior changes.
3. Run specs and RuboCop locally.
4. Open a PR with clear behavior notes and risk areas (especially payments/admin flows).
