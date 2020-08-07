#!/usr/bin/env sh
# shellcheck disable=SC2140

set -eu

this_dir="$(cd "$(dirname "$0")" && pwd)"

# shellcheck disable=SC1090
. "${this_dir}/../helpers/functions.sh"

setup_kubeconfig

echo "$WEB_TLS_CERT" > web_tls_cert.pem
echo "$WEB_TLS_KEY" > web_tls_key.pem
echo "$WORKER_KEY" > worker_key.pem
echo "$WORKER_KEY_PUB" > worker_key_pub.pem

helm --kubeconfig=kubeconfig.json repo add concourse https://concourse-charts.storage.googleapis.com

install_helm_diff

echo "Changes to be applied:"
helm diff upgrade "$ENV" concourse/concourse \
  --values concourse-helm-repo/helm-vars/custom_values.yml \
  --set-file secrets.webTlsCert=web_tls_cert.pem,secrets.webTlsKey=web_tls_key.pem,secrets.workerKey=worker_key.pem,secrets.workerKeyPub=worker_key_pub.pem \
  --set secrets.localUsers="admin:$ADMIN_PASSWORD",web.service.api.loadBalancerIP="$LB_IP",concourse.web.externalUrl="https://$WEB_DOMAIN" \
  --kubeconfig=kubeconfig.json \
  --install \
  --namespace "$ENV" \
  --suppress-secrets

echo "Performing upgrade"
helm upgrade "$ENV" concourse/concourse \
  --values concourse-helm-repo/helm-vars/custom_values.yml \
  --set-file secrets.webTlsCert=web_tls_cert.pem,secrets.webTlsKey=web_tls_key.pem,secrets.workerKey=worker_key.pem,secrets.workerKeyPub=worker_key_pub.pem \
  --set secrets.localUsers="admin:$ADMIN_PASSWORD",web.service.api.loadBalancerIP="$LB_IP",concourse.web.externalUrl="https://$WEB_DOMAIN" \
  --kubeconfig=kubeconfig.json \
  --install \
  --namespace "$ENV" \
  --create-namespace \
  --atomic
