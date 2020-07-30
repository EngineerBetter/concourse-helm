#!/usr/bin/env sh
# shellcheck disable=SC2140

# https://ahmet.im/blog/authenticating-to-gke-without-gcloud/

set -eu
echo "$KUBECONFIG_CONTENTS" > kubeconfig.json
echo "$GOOGLE_APPLICATION_CREDENTIALS_CONTENTS" > google_creds.json

export GOOGLE_APPLICATION_CREDENTIALS=google_creds.json

jq -r '.web_tls_cert' terraform-keys-and-certs/metadata > web_tls_cert.pem
jq -r '.web_tls_key' terraform-keys-and-certs/metadata > web_tls_key.pem
jq -r '.worker_key' terraform-keys-and-certs/metadata > worker_key.pem
jq -r '.worker_key_pub' terraform-keys-and-certs/metadata > worker_key_pub.pem

helm --kubeconfig=kubeconfig.json repo add concourse https://concourse-charts.storage.googleapis.com

helm upgrade "$ENV" concourse/concourse \
  --values concourse-helm-repo/helm-vars/custom_values.yml \
  --set-file secrets.webTlsCert=web_tls_cert.pem,secrets.webTlsKey=web_tls_key.pem,secrets.workerKey=worker_key.pem,secrets.workerKeyPub=worker_key_pub.pem \
  --set secrets.localUsers="admin:$ADMIN_PASSWORD",web.service.api.loadBalancerIP="$LB_IP",concourse.web.externalUrl="https://$WEB_DOMAIN" \
  --kubeconfig=kubeconfig.json \
  --install \
  --namespace "$ENV" \
  --create-namespace \
  --atomic \
  --dry-run
