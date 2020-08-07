# Concourse Helm

A spiked pipeline for deploying Concourse on GKE using helm

## Required params

```sh
credhub generate \
  --name=/concourse/main/concourse-helm/worker_key
  --type=ssh

credhub generate \
  --name=/concourse/main/concourse-helm/web_ca \
  --type=certificate \
  --is-ca \
  --common-name=ConcourseCA

credhub generate \
  --name=/concourse/main/concourse-helm/web_tls \
  --type=certificate \
  --ca=/concourse/main/concourse-helm/web_ca \
  --common-name=<web_domain>
```

```yaml
---
credentials:
- name: /concourse/main/concourse-helm/web_domain
  type: value
  value:

- name: /concourse/main/concourse-helm/terraform_state_bucket
  type: value
  value:

# Password for logging into Concourse as admin
- name: /concourse/main/concourse-helm/admin_password
  type: value
  value:

# Pre-configured static IP in GCP for use with web load balancer
- name: /concourse/main/concourse-helm/web_lb_ip
  type: value
  value:

# Pre-configured static IP in GCP for use with grafana load balancer
- name: /concourse/main/concourse-helm/grafana_lb_ip
  type: value
  value:

# https://ahmet.im/blog/authenticating-to-gke-without-gcloud/
# nest the entire kubeconfig.yml contents under value
- name: /concourse/main/concourse-helm/kubeconfig
  type: json
  value:

# JSON key for a GCP service account with the Kubenetes Engine Admin role
- name: /concourse/main/concourse-helm/gcp_service_account_json
  type: json
  value:
    {}
```

## Setting the pipeline

The pipeline will set itself.

To set it for the first time use:

```sh
fly --target target \
  set-pipeline \
  --pipeline=<env>-helm \
  --config=ci/pipeline.yml \
  --var env=<env>
```

## Acknowledgment

Getting the scripts to connect to GKE using a GCP service account is based on [this blog post](https://ahmet.im/blog/authenticating-to-gke-without-gcloud/)
