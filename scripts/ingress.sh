#!/bin/bash
#
# Deploys the Kubernetes Ingress when enabled in settings.yaml

set -euxo pipefail

config_path="/vagrant/configs"

INGRESS_VERSION=$(grep -E '^\s*ingress:' /vagrant/settings.yaml | sed -E 's/[^:]+: *//' | tr -d '\n\r')
if [ -n "${INGRESS_VERSION}" ]; then
  echo "Deploying Ingress..."
  sudo -i -u vagrant kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v${INGRESS_VERSION}/deploy/static/provider/cloud/deploy.yaml"
fi
