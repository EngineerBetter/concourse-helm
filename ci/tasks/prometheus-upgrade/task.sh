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
