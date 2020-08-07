#!/usr/bin/env sh
# shellcheck disable=SC2140

set -eu
echo "$KUBECONFIG_CONTENTS" > kubeconfig.json
echo "$GOOGLE_APPLICATION_CREDENTIALS_CONTENTS" > google_creds.json

export GOOGLE_APPLICATION_CREDENTIALS=google_creds.json

helm --kubeconfig=kubeconfig.json repo add stable https://kubernetes-charts.storage.googleapis.com

if ! helm --kubeconfig=kubeconfig.json plugin install https://github.com/databus23/helm-diff ; then
  diff_plugin_installed_version=$(helm --kubeconfig=kubeconfig.json plugin list | grep diff | awk '{print $2}')
  diff_plugin_latest_version=$(cat helm-diff-release/version)

  if [ "${diff_plugin_installed_version}" != "${diff_plugin_latest_version}" ]; then
    helm --kubeconfig=kubeconfig.json plugin update diff
  fi
fi

echo "Changes to be applied:"
helm diff upgrade prometheus stable/prometheus \
  --kubeconfig=kubeconfig.json \
  --install \
  --namespace prometheus \
  --suppress-secrets

echo "Performing upgrade"
helm upgrade prometheus stable/prometheus \
  --kubeconfig=kubeconfig.json \
  --install \
  --namespace prometheus \
  --create-namespace \
  --atomic
