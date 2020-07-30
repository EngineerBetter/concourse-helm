#!/usr/bin/env sh

set -eu

echo "$KUBECONFIG_CONTENTS" > kubeconfig.yml

sleep 500
