#!/usr/bin/env bash

set -euo pipefail

function deleteAllSecrets() {
  set +e
  echo "Deleting secrets in concourse-test namespace"
  kubectl --kubeconfig=kubeconfig.json \
    delete secret \
    --namespace=concourse-test \
    secrets
  kubectl --kubeconfig=kubeconfig.json \
    delete secret \
    --namespace=concourse-test \
    team-password
  kubectl --kubeconfig=kubeconfig.json \
    delete secret \
    --namespace=concourse-test \
    test-pipeline.pipeline-password
  kubectl --kubeconfig=kubeconfig.json \
    delete secret \
    --namespace=concourse-test \
    test-pipeline.pipeline-secrets
  set -e
}

function cleanup() {
  status=$?
  deleteAllSecrets
  exit $status
}

this_dir="$(cd "$(dirname "$0")" && pwd)"

# shellcheck disable=SC1090
. "${this_dir}/../helpers/functions.sh"

setup_kubeconfig

trap cleanup EXIT
deleteAllSecrets

fly --target test login \
  --concourse-url="https://${WEB_DOMAIN}" \
  --username=admin \
  --password="${ADMIN_PASSWORD}" \
  --team-name=test \
  --insecure

echo "Setting secrets in test namespace"
kubectl --kubeconfig=kubeconfig.json \
  create \
  --filename=concourse-helm-repo/ci/tasks/test/team-scoped-secret.yml

kubectl --kubeconfig=kubeconfig.json \
  create \
  --filename=concourse-helm-repo/ci/tasks/test/pipeline-scoped-secret.yml

kubectl --kubeconfig=kubeconfig.json \
  create \
  --filename=concourse-helm-repo/ci/tasks/test/nested-team-scoped-secret.yml

kubectl --kubeconfig=kubeconfig.json \
  create \
  --filename=concourse-helm-repo/ci/tasks/test/nested-pipeline-scoped-secret.yml

echo "Ensuring test team exists"
fly --target=test \
  set-team \
  --team-name=test \
  --local-user=admin \
  --non-interactive

echo "Setting test pipeline"
fly --target=test set-pipeline \
  --pipeline=test-pipeline \
  --config=concourse-helm-repo/ci/tasks/test/pipeline.yml \
  --non-interactive

echo "Unpausing test pipeline"
fly --target=test unpause-pipeline \
  --pipeline=test-pipeline

echo "Running test pipeline"
fly --target=test trigger-job \
  --job=test-pipeline/run-test \
  --watch

echo "Deleting test pipeline"
fly --target=test destroy-pipeline \
  --pipeline=test-pipeline \
  --non-interactive
