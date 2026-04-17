# DevOps Final Project Checklist (Authoritative)

This checklist replaces the old setup-only list and tracks delivery against `task/devops_final_project_exercise_improved.pdf` plus implementation details from `task/DEVOPS_BLUEPRINT.md`.

Use this as the single source of truth for:
- what is already working and tested,
- what still needs implementation,
- what is optional bonus work.

---

## 1) PDF Task Coverage

### 1. Containerization + Kubernetes Deployment
- [x] Engine container Dockerfile exists: `docker/dockerfile.engine`
- [x] CLI container Dockerfile exists: `docker/dockerfile.cli`
- [x] Kubernetes manifests exist under `helm/seyoawe-app/templates/` (Helm chart)
- [x] Engine deployed as StatefulSet with probes + PVC + Service
- [x] CLI deployed as utility Deployment alongside the Engine

### 2–3. Unified CI Pipeline (Engine + CLI)
- [x] CI workflow exists: `.github/workflows/ci-pipeline.yml`
- [x] Docker Compose test stack + `pytest` (unit / integration / e2e)
- [x] Builds and pushes **both** engine and CLI images on default branch after green tests
- [x] Guards engine binary via Docker build context (`Engine/seyoawe.linux`)

### 4. Version Coupling (Engine + CLI)
- [x] Shared minor SemVer bump + git tag in `ci-pipeline.yml` (`build-and-push` job)
- [ ] Optional: path-based rebuild skips (only rebuild what changed)
- [ ] Optional: smarter bumping strategy (conventional commits / release rules)

### 5. Continuous Deployment Pipeline
- [x] Real CD workflow: `.github/workflows/cd-deploy-aws.yml` (Terraform apply → Ansible → Helm)
- [x] Paired teardown workflow: `.github/workflows/cd-destroy-aws.yml`
- [x] Terraform at `infrastructure/terraform/` provisions VPC, EKS, IAM/OIDC, EBS CSI addon
- [x] Ansible at `infrastructure/ansible/deploy.yml` installs StorageClass, metrics-server,
      Kubernetes Dashboard + password-protected reverse proxy, and the seyoawe Helm release

### 6. Observability (Bonus)
- [x] `metrics-server` installed for in-cluster resource metrics
- [x] Kubernetes Dashboard installed (public URL protected by `DASHBOARD_ADMIN_PASSWORD`)
- [ ] Optional future work: Prometheus + Grafana + alert rules

---

## 2) What Is Already Working and Tested

### Runtime and Repo Layout
- [x] New structure is active: `Engine/`, `CLI/`, `helm/`, `infrastructure/`, `scripts/`, `schemes/`, `task/`
- [x] Engine runs from `Engine/run.sh`
- [x] `Engine/configuration/config.yaml` uses local relative directories and `customer_id: default`
- [x] Webform assets helper flow in place (`link_assets.sh`, `serve_webform_assets.py`)

### CLI
- [x] Linux CLI binary works from `CLI/sawectl/binaries/linux/sawectl`
- [x] `CLI/sawectl/build_cli.sh` exists and rebuilds Linux binary
- [x] Binary packaging includes required schema files (`dsl.schema.json`, `module.schema.json`)
- [x] `sawectl run` supports endpoint fallback compatible with current engine API

### Tests and Validation
- [x] Local tests pass: `python -m pytest -q tests`
- [x] Workflow validation passes in WSL for:
  - `Engine/workflows/default/hello-world.yaml`
  - `Engine/workflows/default/hello_logger.yaml`
- [x] WSL Docker build passes for engine image

---

## 3) Infrastructure Layout (Implemented)

### Terraform (`infrastructure/terraform/`)
- [x] `backend.tf` (S3 remote state with native S3 locking)
- [x] `versions.tf` (terraform + provider version pinning)
- [x] `providers.tf` (AWS provider)
- [x] `main.tf` (VPC, public subnets, EKS, IAM/OIDC, EBS CSI addon, SPOT node group)
- [x] `variables.tf`
- [x] `outputs.tf`

### Ansible (`infrastructure/ansible/`)
- [x] `deploy.yml` — single playbook that installs the `gp3` StorageClass,
      `metrics-server`, the Kubernetes Dashboard, the password-protected
      nginx reverse proxy (with TLS + admin token injection), and the
      seyoawe Helm release.

### Helm chart (`helm/seyoawe-app/`)
- [x] `Chart.yaml`, `values.yaml`
- [x] `templates/engine-statefulset.yaml`
- [x] `templates/engine-service.yaml`
- [x] `templates/cli-deployment.yaml`
- [x] `templates/cli-configmap.yaml`

### Operator scripts (`scripts/`)
- [x] `open-dashboard.sh` — local port-forward to the Dashboard (zero ELB cost)
- [x] `sawectl.sh` — runs `sawectl` inside the deployed CLI pod via `kubectl exec`

---

## 4) Remaining Work (Optional)

### Hardening
- [ ] Add linting gates (`ruff`/`flake8`) to CI jobs
- [ ] Add coverage reporting and minimum threshold gate
- [ ] Add image security scan (Trivy) and optional SBOM/signing

### Bonus Observability
- [ ] Add Prometheus + Grafana (via Helm chart in the Ansible playbook)
- [ ] Add basic alerts (engine health, CPU/memory, crash loops)

---

## 5) Required Secrets / Variables

### Secrets (in GitHub → Settings → Secrets and variables → Actions)
- [x] `DOCKER_USERNAME`, `DOCKER_PASSWORD`
- [x] `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- [x] `DASHBOARD_ADMIN_PASSWORD`
- [ ] Optional: `JIRA_*`, `EMAIL_*` for CI failure notifications

### Variables
- [x] `AWS_REGION`

---

## 6) Validation Commands

```bash
# local tests
python -m pytest -q tests

# WSL CLI checks
./CLI/sawectl/binaries/linux/sawectl --help
./CLI/sawectl/binaries/linux/sawectl validate-workflow --workflow Engine/workflows/default/hello-world.yaml --modules Engine/modules
./CLI/sawectl/binaries/linux/sawectl validate-workflow --workflow Engine/workflows/default/hello_logger.yaml --modules Engine/modules

# WSL Docker checks
docker build -f docker/dockerfile.engine -t seyoawe-engine:check .
docker build -f docker/dockerfile.cli -t seyoawe-cli:check .
```

---

## 7) Notes

- PDF mentions Jenkins; this project uses GitHub Actions as approved replacement.
- Keep this checklist synchronized with `task/DEVOPS_BLUEPRINT.md`.
