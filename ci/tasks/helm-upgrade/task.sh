#!/usr/bin/env sh
# shellcheck disable=SC2140

set -eu
echo "$KUBECONFIG_CONTENTS" > kubeconfig.json
echo "$GOOGLE_APPLICATION_CREDENTIALS_CONTENTS" > google_creds.json

export GOOGLE_APPLICATION_CREDENTIALS=google_creds.json

echo "$WEB_TLS_CERT" > web_tls_cert.pem
echo "$WEB_TLS_KEY" > web_tls_key.pem
echo "$WORKER_KEY" > worker_key.pem
echo "$WORKER_KEY_PUB" > worker_key_pub.pem

helm --kubeconfig=kubeconfig.json repo add concourse https://concourse-charts.storage.googleapis.com

if ! helm --kubeconfig=kubeconfig.json plugin install https://github.com/databus23/helm-diff ; then
  diff_plugin_installed_version=$(helm --kubeconfig=kubeconfig.json plugin list | grep diff | awk '{print $2}')
  diff_plugin_latest_version=$(cat helm-diff-release/version)

  if [ "${diff_plugin_installed_version}" != "${diff_plugin_latest_version}" ]; then
    helm --kubeconfig=kubeconfig.json plugin update diff
  fi
fi

helm_flags=$(cat << FLAGS
--values concourse-helm-repo/helm-vars/custom_values.yml \
--set-file secrets.webTlsCert=web_tls_cert.pem,secrets.webTlsKey=web_tls_key.pem,secrets.workerKey=worker_key.pem,secrets.workerKeyPub=worker_key_pub.pem \
--set secrets.localUsers="admin:$ADMIN_PASSWORD",web.service.api.loadBalancerIP="$LB_IP",concourse.web.externalUrl="https://$WEB_DOMAIN" \
--kubeconfig=kubeconfig.json \
--install \
--namespace "$ENV"
FLAGS
)

echo "Changes to be applied:"
helm diff upgrade "$ENV" concourse/concourse \
  "${helm_flags}" \
  --suppress-secrets

echo "Performing upgrade"
helm upgrade "$ENV" concourse/concourse \
  "${helm_flags}" \
  --create-namespace \
  --atomic
