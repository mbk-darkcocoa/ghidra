# Monorepo Deployment Runbook

## Trigger Conditions
- Manual promotion uses `.github/workflows/orchestrate-monorepo-deploy.yml` with `workflow_dispatch`.
- Release managers may set `release_version`; otherwise the reusable deploy contract generates an immutable value from UTC date, run number, and commit SHA.
- Domain ownership and live-space mapping are sourced from `.github/deployment/domains.json`.

## Promotion Policy
- Promotion order is strictly `dev -> staging -> prod`.
- Each space enforces explicit domain sequencing: `infrastructure -> services -> apps`.
- Space promotion gates are represented by `verify-dev-gate`, `verify-staging-gate`, and `verify-prod-gate` jobs.
- A gate is eligible only if health checks, smoke tests, and dependency checks pass in the reusable deploy contract.

## Rollback Policy
- Each domain deployment can define a `rollback_command` through the reusable deploy contract.
- Rollback is triggered automatically when deployment or verification fails for a domain.
- Production promotion halts until failed space rollback completes and incident owners approve a retrigger.

## Ownership Matrix
| Domain | Component | Owner repository | Dependencies | Live spaces |
| --- | --- | --- | --- | --- |
| infrastructure | platform-foundation | mbk-darkcocoa/ghidra | none | dev, staging, prod |
| services | ghidra-services | mbk-darkcocoa/ghidra | platform-foundation | dev, staging, prod |
| apps | ghidra-application | mbk-darkcocoa/ghidra | ghidra-services | dev, staging, prod |

## Environment Approvals and Protection Rules
- Space policies are declared in `.github/deployment/live-spaces.json`.
- Configure GitHub Environments named `dev`, `staging`, and `prod` to match those policies:
  - required reviewers
  - wait timers
  - scoped secrets
- Map deployment secrets by space:
  - `DEPLOYMENT_TOKEN_DEV`, `DEPLOYMENT_TOKEN_STAGING`, `DEPLOYMENT_TOKEN_PROD`
  - `ALERT_WEBHOOK_DEV`, `ALERT_WEBHOOK_STAGING`, `ALERT_WEBHOOK_PROD`

## CI Baseline Standardization
- Baseline workflow contract is defined in `.github/deployment/ci-baselines.json`.
- Required baselines:
  - `.github/workflows/build-ghidra.yml`
  - `.github/workflows/build-ghidra-multi-platform-artifact.yml`
  - `.github/workflows/codeql.yml`
  - `.github/workflows/dependency-submission.yml`
- `.github/workflows/ci-baseline-compliance.yml` blocks changes that remove baseline workflows.

## Observability and Incident Controls
- Reusable deploy workflow writes release metadata and deployment logs as workflow artifacts.
- Every deployment appends a concise outcome report to `GITHUB_STEP_SUMMARY`.
- On failure, alert notifications are sent to `ALERT_WEBHOOK` when configured.
- Incident triage should include release version, domain, component, run ID, and rollback result from artifacts.
