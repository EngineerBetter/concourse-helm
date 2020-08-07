#!/usr/bin/env sh

setup_kubeconfig() {
  echo "$KUBECONFIG_CONTENTS" > kubeconfig.json
  echo "$GOOGLE_APPLICATION_CREDENTIALS_CONTENTS" > google_creds.json

  export GOOGLE_APPLICATION_CREDENTIALS=google_creds.json
}

install_helm_diff() {
  if ! helm --kubeconfig=kubeconfig.json plugin install https://github.com/databus23/helm-diff ; then
    diff_plugin_installed_version=$(helm --kubeconfig=kubeconfig.json plugin list | grep diff | awk '{print $2}')
    diff_plugin_latest_version=$(cat helm-diff-release/version)

    if [ "${diff_plugin_installed_version}" != "${diff_plugin_latest_version}" ]; then
      helm --kubeconfig=kubeconfig.json plugin update diff
    fi
  fi
}
