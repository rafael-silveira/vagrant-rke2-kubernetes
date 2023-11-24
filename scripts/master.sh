#!/bin/bash
#
# Setup for Control Plane (Master) servers

set -euxo pipefail

NODENAME=$(hostname -s)

# copia arquivo de configuracao
sudo mkdir -p /etc/rancher/rke2/
sudo cat <<EOF >>/etc/rancher/rke2/config.yaml
node-external-ip: ${CLUSTER_MASTER_IP}
token: vagrant-rke2
cni: calico
EOF

# instala rke2
#curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_VERSION=v1.25.15+rke2r2 sh -
curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_VERSION=${RKE2_VERSION} sh -
sudo systemctl enable rke2-server.service
sudo systemctl start rke2-server.service

#configura 
mkdir -p /home/vagrant/.kube && sudo cp /etc/rancher/rke2/rke2.yaml /home/vagrant/.kube/config
sudo chown 1000:1000 /home/vagrant/.kube/config
sudo cp /var/lib/rancher/rke2/bin/kubectl /usr/bin

#copia config para diretorio externo e troca 127.0.0.1 pelo master node
mkdir -p /vagrant/configs/config
sed "s/127.0.0.1/${CLUSTER_MASTER_IP}/" /home/vagrant/.kube/config > /vagrant/configs/config

