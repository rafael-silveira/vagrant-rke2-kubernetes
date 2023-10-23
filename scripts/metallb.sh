#!/bin/bash
#
# Deploys the Kubernetes MetalLB when enabled in settings.yaml

set -euxo pipefail

config_path="/vagrant/configs"

METALLB_VERSION=$(grep -E '^\s*metallb:' /vagrant/settings.yaml | sed -E 's/[^:]+: *//' | tr -d '\n\r')
if [ -n "${METALLB_VERSION}" ]; then
  echo "Deploying metallb..."  
  sudo -i -u vagrant kubectl apply -f "https://raw.githubusercontent.com/metallb/metallb/v${METALLB_VERSION}/config/manifests/metallb-native.yaml"

  echo "Waiting metallb be published..."
  sudo -i -u vagrant kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=180s

  echo "Deploying metallb configmap..."
  cat <<EOF | sudo -i -u vagrant kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 10.0.0.200-10.0.0.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
EOF

fi
