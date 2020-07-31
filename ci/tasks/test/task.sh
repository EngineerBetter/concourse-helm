#!/usr/bin/env bash

set -euo pipefail

echo "$KUBECONFIG_CONTENTS" > kubeconfig.json
echo "$GOOGLE_APPLICATION_CREDENTIALS_CONTENTS" > google_creds.json

export GOOGLE_APPLICATION_CREDENTIALS=google_creds.json

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
  --pipeline=test-concourse \
  --non-interactive

echo "Deleting secrets in test namespace"
kubectl --kubeconfig=kubeconfig.json \
  delete secrets \
  --namespace=test \
  --all
