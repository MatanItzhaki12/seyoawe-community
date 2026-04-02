# DevOps Blueprint (GitHub Actions)

This blueprint defines the remaining implementation work after the initial CI/CD scaffold.
It aligns with the project PDF requirements and the architecture diagrams.

## Current Baseline

- GitHub Actions workflows added:
  - `.github/workflows/ci-engine.yml`
  - `.github/workflows/ci-cli.yml`
  - `.github/workflows/release-and-deploy.yml`
- Starter Dockerfiles:
  - `docker/dockerfile.engine`
  - `docker/dockerfile.cli`
- Basic test scaffolding:
  - `tests/test_unit.py`
  - `tests/test_integration.py`

## Target Architecture Mapping

- Source control and pipeline triggers: GitHub + GitHub Actions
- Artifact storage: Docker Hub (`seyoawe-engine`, `seyoawe-cli`)
- Runtime platform: Kubernetes (AWS EKS in diagrams)
- Infra lifecycle: Terraform
- Host/bootstrap configuration: Ansible
- Observability: Prometheus + Grafana

## Implementation Backlog

## 1) Harden CI Quality Gates

- Add `ruff`/`flake8` linting for Python code.
- Split test stages into unit and integration jobs with explicit reports.
- Add coverage output and enforce a minimum threshold.
- Add PR status checks as merge requirements.

## 2) Shared Semantic Versioning (Engine + CLI)

- Keep a single shared SemVer generated in `release-and-deploy.yml`.
- Promote from naive patch bump to conventional commits or release notes based bumping.
- Persist version into a generated artifact file, for example `build/version.txt`.
- Include the same version in both image tags and release tag.

## 3) Container Security and Supply Chain

- Add image scanning (for example Trivy) before push.
- Generate SBOM for each image.
- Sign images (cosign) for provenance.
- Add dependency vulnerability checks in CI.

## 4) Terraform Stack

Create `terraform/` with at least:

- `providers.tf`: cloud + kubernetes providers
- `versions.tf`: terraform + provider version pinning
- `main.tf`: base network and cluster modules
- `variables.tf`: region, cluster name, node sizing
- `outputs.tf`: kubeconfig outputs, endpoint, cluster id
- `environments/dev.tfvars` and `environments/prod.tfvars`

Pipeline behavior:

- On main deployment workflow: `terraform init`, `terraform plan`, manual approval gate, `terraform apply`.
- Upload plan output as artifact for review.

## 5) Ansible Configuration Layer

Create `ansible/` with:

- `inventory/` (dynamic or static)
- `playbooks/bootstrap.yml`
- `playbooks/k8s_prereqs.yml`
- `roles/common`, `roles/container_runtime`, `roles/observability_agents`

Pipeline behavior:

- Run `ansible-lint`.
- Execute bootstrap playbooks after successful Terraform apply.

## 6) Kubernetes Deployment

Create `k8s/` manifests for:

- Namespace
- Engine `StatefulSet` with:
  - readiness probe
  - liveness probe
  - resource requests/limits
  - persistent volume claim
- Service and ingress
- CLI utility deployment strategy (Job/CronJob or deployment utility pod)

Deployment strategy:

- Use rolling updates for engine.
- Use image tags from shared SemVer.
- Add rollback command docs and health-check verification steps.

## 7) Observability (Bonus)

Create `monitoring/` with:

- Prometheus scrape config for app and cluster metrics
- Grafana dashboards (JSON exports)
- Basic alert rules:
  - engine health failures
  - high CPU/memory
  - crash loop detection

## 8) CD Workflow Completion

In `.github/workflows/release-and-deploy.yml` replace placeholder deploy job with:

1. Terraform plan/apply
2. Ansible playbooks
3. Kubernetes apply/upgrade
4. Post-deploy smoke tests
5. Notification (Slack/email) on success/failure

## Required Secrets and Variables

Repository secrets:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- Cloud credentials (provider-specific)
- `KUBECONFIG` or workload identity setup
- Optional: `SLACK_WEBHOOK_URL`

Repository variables:

- `CLOUD_REGION`
- `K8S_NAMESPACE`
- `TERRAFORM_WORKSPACE`

## Recommended Next Steps

1. Validate current workflows in PR mode.
2. Add Terraform and Ansible skeletons.
3. Implement K8s stateful deployment manifests.
4. Wire deploy stage end-to-end in GitHub Actions.
5. Add observability as final milestone.
