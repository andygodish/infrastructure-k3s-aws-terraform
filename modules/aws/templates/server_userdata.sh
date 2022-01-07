#!/bin/bash

# apt-get update -y
# apt-get install -y curl python-pip

# export K3S_NODE_NAME="$(hostname).${region}.compute.internal"
export K3S_NODE_NAME="$(hostname).ec2.internal"
export K3S_TOKEN="${k3s_token}"
export SERVER_IP="https://${server_ip}:6443"

mkdir -p /etc/rancher/k3s

cat << EOF > /etc/rancher/k3s/config.yaml
server: $SERVER_IP
disable-cloud-controller: true
token: $K3S_TOKEN
EOF

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.21.7+k3s1 sh -s - server \
  --kubelet-arg="cloud-provider=external" \
  --kubelet-arg="provider-id=aws:///$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"

echo "Waiting for k3s config file to exist.."
while [[ ! -f /etc/rancher/k3s/k3s.yaml ]]; do
  sleep 2
done

# echo "Installing cloud controller RBAC"
# curl https://raw.githubusercontent.com/andygodish/infrastructure-k3s-aws-terraform/main/manifests/aws-cloud-provider.yaml | kubectl apply -f -

cp /etc/rancher/k3s/k3s.yaml /tmp/k3s.yaml
sed -i -e "s/127.0.0.1/${cp_lb_host}/g" /tmp/k3s.yaml