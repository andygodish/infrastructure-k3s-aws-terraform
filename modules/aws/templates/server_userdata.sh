#!/bin/bash

# apt-get update -y
# apt-get install -y curl python-pip

export K3S_NODE_NAME="$(hostname).ec2.internal"

mkdir -p /etc/rancher/k3s

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --server https://${server_ip}:6443" \
  K3S_TOKEN=${k3s_token} sh -s -

echo "Waiting for k3s config file to exist.."
while [[ ! -f /etc/rancher/k3s/k3s.yaml ]]; do
  sleep 2
done

cp /etc/rancher/k3s/k3s.yaml /tmp/k3s.yaml
sed -i -e "s/127.0.0.1/${cp_lb_host}/g" /tmp/k3s.yaml