#!/bin/bash
#
# Setup for Node servers

set -euxo pipefail

sudo mkdir -p /etc/rancher/rke2/
sudo cat <<EOF >>/etc/rancher/rke2/config.yaml
node-external-ip: ${CLUSTER_NODE_IP}
server: https://${CLUSTER_MASTER_IP}:9345
token: vagrant-rke2
EOF

# instala rke2
#curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_VERSION=v1.25.15+rke2r2 INSTALL_RKE2_TYPE="agent" sh -
curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_VERSION=${RKE2_VERSION} INSTALL_RKE2_TYPE="agent" sh -

sudo systemctl enable rke2-agent.service

sudo systemctl start rke2-agent.service
