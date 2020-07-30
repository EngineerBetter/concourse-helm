#!/usr/bin/env sh

# https://ahmet.im/blog/authenticating-to-gke-without-gcloud/

set -eu

echo "$KUBECONFIG_CONTENTS" > kubeconfig.json
echo "$GOOGLE_APPLICATION_CREDENTIALS_CONTENTS" > google_creds.json

export GOOGLE_APPLICATION_CREDENTIALS=google_creds.json

sleep 500
