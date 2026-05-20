#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-amq}"
BROKER_NAME="${BROKER_NAME:-amq-broker}"
QUEUE="${QUEUE:-showLines}"
LINE_COUNT="${LINE_COUNT:-650}"
AMQ_USER="${AMQ_USER:-admin}"
AMQ_PASSWORD="${AMQ_PASSWORD:-admin}"
POD="${POD:-${BROKER_NAME}-ss-0}"
URL="${URL:-tcp://${POD}.${BROKER_NAME}-hdls-svc.${NAMESPACE}.svc.cluster.local:61616}"

oc get pod "${POD}" -n "${NAMESPACE}" >/dev/null

ARTEMIS_BIN="$(
  oc exec "${POD}" -n "${NAMESPACE}" -- sh -c '
    for candidate in /home/jboss/amq-broker/bin/artemis /opt/amq/bin/artemis /amq-broker/bin/artemis; do
      if [ -x "$candidate" ]; then
        printf "%s" "$candidate"
        exit 0
      fi
    done
    command -v artemis
  '
)"

PAYLOAD="$(
  awk -v count="${LINE_COUNT}" 'BEGIN {
    print "{"
    print "  \"type\": \"console-line-limit-demo\","
    print "  \"valid\": true,"
    print "  \"lines\": ["
    for (i = 1; i <= count; i++) {
      comma = i < count ? "," : ""
      printf "    {\"id\": %d, \"value\": \"linha-%04d\"}%s\n", i, i, comma
    }
    print "  ]"
    print "}"
  }'
)"

oc exec "${POD}" -n "${NAMESPACE}" -- "${ARTEMIS_BIN}" producer \
  --url "${URL}" \
  --user "${AMQ_USER}" \
  --password "${AMQ_PASSWORD}" \
  --destination "queue://${QUEUE}" \
  --message-count 1 \
  --message "${PAYLOAD}"

echo "Mensagem enviada para queue://${QUEUE} com ${LINE_COUNT} linhas."
