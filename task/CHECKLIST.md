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
- [ ] Kubernetes manifests exist under `k8s/`
- [ ] Engine deployed as StatefulSet with probes + PVC + service

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
- [x] CD placeholder workflow: `.github/workflows/cd-deploy-aws.yml` (Terraform/Ansible/K8s echoes)
- [x] Infra skeleton exists at `infra/terraform/` and `infra/ansible/`
- [ ] Replace CD placeholders with real Terraform + Ansible + Kubernetes steps

### 6. Observability (Bonus)
- [ ] `monitoring/` folder with Prometheus + Grafana config
- [ ] Alert rules and dashboard exports

---

## 2) What Is Already Working and Tested

### Runtime and Repo Layout
- [x] New structure is active: `Engine/`, `CLI/`, `infra/`, `schemes/`, `task/`
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

## 3) Infra Skeleton Status (Ready to Fill)

### Terraform placeholders
- [x] `infra/terraform/providers.tf`
- [x] `infra/terraform/versions.tf`
- [x] `infra/terraform/main.tf`
- [x] `infra/terraform/variables.tf`
- [x] `infra/terraform/outputs.tf`
- [x] `infra/terraform/environments/dev.tfvars`
- [x] `infra/terraform/environments/prod.tfvars`

### Ansible placeholders
- [x] `infra/ansible/inventory/hosts.yml`
- [x] `infra/ansible/playbooks/bootstrap.yml`
- [x] `infra/ansible/playbooks/k8s_prereqs.yml`
- [x] `infra/ansible/roles/common/README.md`
- [x] `infra/ansible/roles/container_runtime/README.md`
- [x] `infra/ansible/roles/observability_agents/README.md`

---

## 4) Remaining Work (Execution Order)

### Phase A: Complete Deployable Platform
- [ ] Add `k8s/` manifests (namespace, StatefulSet, service, ingress/PVC)
- [ ] Implement real deploy job in `cd-deploy-aws.yml`:
  - `terraform init/plan/apply`
  - ansible playbook execution
  - `kubectl apply` or Helm rollout
  - post-deploy smoke tests

### Phase B: Harden CI/CD
- [ ] Add linting gates (`ruff`/`flake8`) to CI jobs
- [ ] Add coverage reporting and minimum threshold gate
- [ ] Add image security scan (Trivy) and optional SBOM/signing

### Phase C: Bonus Observability
- [ ] Add `monitoring/` with Prometheus config and Grafana dashboards
- [ ] Add basic alerts (engine health, CPU/memory, crash loops)

---

## 5) Required Secrets / Variables

### Secrets
- [ ] `DOCKERHUB_USERNAME`
- [ ] `DOCKERHUB_TOKEN`
- [ ] cloud provider credentials
- [ ] `KUBECONFIG` or workload identity setup
- [ ] optional: `SLACK_WEBHOOK_URL`

### Variables
- [ ] `CLOUD_REGION`
- [ ] `K8S_NAMESPACE`
- [ ] `TERRAFORM_WORKSPACE`

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
