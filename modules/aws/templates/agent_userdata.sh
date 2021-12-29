#!/bin/bash

export CP_LB_HOST="${cp_lb_host}"
export K3S_TOKEN="${k3s_token}"
export K3S_NODE_NAME="$(hostname).${region}.compute.internal"

mkdir -p /etc/rancher/k3s

cat << EOF > /etc/rancher/k3s/config.yaml
token: $K3S_TOKEN
server: https://$CP_LB_HOST:6443
EOF

curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=v1.21.7+k3s1 sh -s - agent \
    --kubelet-arg="cloud-provider=external" \
    --kubelet-arg="provider-id=aws:///$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"