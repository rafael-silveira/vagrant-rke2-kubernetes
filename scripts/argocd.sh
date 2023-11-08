#!/bin/bash
#
# Deploys the Kubernetes ArgoCD when enabled in settings.yaml

set -euxo pipefail

config_path="/vagrant/configs"

ARGOCD_VERSION=$(grep -E '^\s*argocd:' /vagrant/settings.yaml | sed -E 's/[^:]+: *//' | tr -d '\n\r')
if [ -n "${ARGOCD_VERSION}" ]; then
  echo "Deploying Ingress..."
  sudo -i -u vagrant kubectl create namespace argocd
  sudo -i -u vagrant kubectl apply -n argocd -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"
fi
