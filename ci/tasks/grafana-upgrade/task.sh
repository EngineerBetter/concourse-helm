#!/usr/bin/env sh
# shellcheck disable=SC2140

set -eu

this_dir="$(cd "$(dirname "$0")" && pwd)"

# shellcheck disable=SC1090
. "${this_dir}/../helpers/functions.sh"

setup_kubeconfig

helm --kubeconfig=kubeconfig.json repo add stable https://kubernetes-charts.storage.googleapis.com

install_helm_diff

echo "Changes to be applied:"
helm diff upgrade grafana stable/grafana \
  --kubeconfig=kubeconfig.json \
  --values concourse-helm-repo/helm-vars/grafana_values.yml \
  --install \
  --namespace grafana \
  --suppress-secrets

echo "Performing upgrade"
helm upgrade grafana stable/grafana \
  --kubeconfig=kubeconfig.json \
  --values concourse-helm-repo/helm-vars/grafana_values.yml \
  --install \
  --namespace grafana \
  --create-namespace \
  --atomic
