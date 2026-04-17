#!/usr/bin/env bash
# Run a sawectl command against the Engine, inside the always-running CLI pod.
#
# Usage:
#   ./scripts/sawectl.sh list-modules
#   ./scripts/sawectl.sh --help
#   ./scripts/sawectl.sh run --workflow /app/workflows/default/hello-world.yaml
#
# Env overrides:
#   CLUSTER_NAME   EKS cluster name (default: seyoawe-eks)
#   AWS_REGION     AWS region (default: from `aws configure` / env)
#
# The CLI `Deployment` is created by the Helm chart and runs `sleep infinity`,
# with SEYOAWE_ENGINE pre-populated via the cli-config ConfigMap. This script
# just does `kubectl exec` into that pod. No ephemeral pod churn, no image
# pull on each call.
#
# Requires: aws, kubectl.

set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <sawectl args...>" >&2
  echo "Example: $0 list-modules" >&2
  exit 2
fi

CLUSTER_NAME="${CLUSTER_NAME:-seyoawe-eks}"
AWS_REGION="${AWS_REGION:-$(aws configure get region 2>/dev/null || true)}"
NAMESPACE="seyoawe"
DEPLOYMENT="deployment/seyoawe-app-cli"

if [[ -z "${AWS_REGION}" ]]; then
  echo "AWS_REGION is not set and no default region is configured." >&2
  exit 1
fi

echo ">> Updating kubeconfig for ${CLUSTER_NAME} in ${AWS_REGION}..." >&2
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}" >/dev/null

if ! kubectl -n "${NAMESPACE}" get "${DEPLOYMENT}" >/dev/null 2>&1; then
  echo "Could not find ${DEPLOYMENT} in namespace ${NAMESPACE}." >&2
  echo "Has the 'CD - Deploy AWS' workflow finished successfully?" >&2
  exit 1
fi

echo ">> Waiting for the CLI pod to be Ready..." >&2
kubectl -n "${NAMESPACE}" rollout status "${DEPLOYMENT}" --timeout=120s >/dev/null

# `-i` attaches stdin so `sawectl` can read piped input; no `-t` so output
# stays plain when invoked non-interactively (CI, redirection).
exec kubectl -n "${NAMESPACE}" exec -i "${DEPLOYMENT}" -- sawectl "$@"
