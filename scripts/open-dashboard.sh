#!/usr/bin/env bash
# Opens the Kubernetes Dashboard locally without any AWS Load Balancer cost.
#
# Usage:
#   ./scripts/open-dashboard.sh                    # cluster name from TF output
#   CLUSTER_NAME=seyoawe-eks AWS_REGION=eu-west-1 ./scripts/open-dashboard.sh
#
# What it does:
#   1. Updates kubeconfig.
#   2. Mints / reads the admin-user token.
#   3. Copies the token to the clipboard when possible and prints it.
#   4. Port-forwards the Dashboard Kong proxy to https://localhost:8443.
#
# Requires: aws, kubectl. `jq` and `pbcopy`/`xclip`/`clip.exe` are optional.

set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-seyoawe-eks}"
AWS_REGION="${AWS_REGION:-$(aws configure get region 2>/dev/null || true)}"
DASHBOARD_NS="kubernetes-dashboard"
LOCAL_PORT="${LOCAL_PORT:-8443}"

if [[ -z "${AWS_REGION}" ]]; then
  echo "AWS_REGION is not set and no default region is configured." >&2
  exit 1
fi

echo ">> Updating kubeconfig for cluster ${CLUSTER_NAME} in ${AWS_REGION}..."
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}" >/dev/null

echo ">> Fetching admin-user token..."
TOKEN=""
if kubectl -n "${DASHBOARD_NS}" get secret admin-user-token >/dev/null 2>&1; then
  TOKEN="$(kubectl -n "${DASHBOARD_NS}" get secret admin-user-token \
    -o jsonpath='{.data.token}' | base64 --decode)"
fi
if [[ -z "${TOKEN}" ]]; then
  TOKEN="$(kubectl -n "${DASHBOARD_NS}" create token admin-user --duration=24h)"
fi

copy_cmd=""
if command -v pbcopy >/dev/null 2>&1; then copy_cmd="pbcopy"; fi
if [[ -z "${copy_cmd}" ]] && command -v xclip >/dev/null 2>&1; then copy_cmd="xclip -selection clipboard"; fi
if [[ -z "${copy_cmd}" ]] && command -v clip.exe >/dev/null 2>&1; then copy_cmd="clip.exe"; fi

if [[ -n "${copy_cmd}" ]]; then
  printf '%s' "${TOKEN}" | eval "${copy_cmd}"
  echo ">> Token copied to clipboard."
fi

cat <<EOF

========================================
Dashboard URL: https://localhost:${LOCAL_PORT}
Login mode:    Token
Token:
${TOKEN}
========================================

Accept the self-signed certificate warning in the browser.
Leave this terminal open. Ctrl-C stops the port-forward.

EOF

exec kubectl -n "${DASHBOARD_NS}" port-forward \
  svc/kubernetes-dashboard-kong-proxy "${LOCAL_PORT}:443"
