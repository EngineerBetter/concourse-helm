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
helm diff upgrade prometheus-operator stable/prometheus-operator \
  --kubeconfig=kubeconfig.json \
  --install \
  --suppress-secrets

echo "Performing upgrade"
helm upgrade prometheus-operator stable/prometheus-operator \
  --kubeconfig=kubeconfig.json \
  --install \
  --create-namespace \
  --atomic
