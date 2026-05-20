#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="${NAMESPACE:-amq}"
BROKER_NAME="${BROKER_NAME:-amq-broker}"
TIMEOUT="${TIMEOUT:-600s}"

oc get namespace "${NAMESPACE}" >/dev/null
oc apply -f "${ROOT_DIR}/manifests/01-amq-broker.yaml"

for _ in {1..60}; do
  if oc get statefulset "${BROKER_NAME}-ss" -n "${NAMESPACE}" >/dev/null 2>&1; then
    break
  fi
  sleep 5
done

oc get statefulset "${BROKER_NAME}-ss" -n "${NAMESPACE}" >/dev/null
oc rollout status statefulset/"${BROKER_NAME}-ss" -n "${NAMESPACE}" --timeout="${TIMEOUT}"
oc wait --for=condition=Ready pod/"${BROKER_NAME}-ss-0" -n "${NAMESPACE}" --timeout="${TIMEOUT}"
oc apply -f "${ROOT_DIR}/manifests/02-console-edge-route.yaml"

"${ROOT_DIR}/scripts/produce-large-message.sh"

echo
echo "Console route:"
oc get route amq-broker-console-edge -n "${NAMESPACE}" -o jsonpath='https://{.spec.host}/console/{"\n"}'
echo
echo "Queue: showLines"
echo "User:  admin"
echo "Pass:  admin"
