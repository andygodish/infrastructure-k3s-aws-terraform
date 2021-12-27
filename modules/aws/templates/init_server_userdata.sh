#!/bin/bash

# apt-get update -y
# apt-get install -y curl python-pip

export CP_LB_HOST="${cp_lb_host}" # Needed to pick up in heredoc
export K3S_TOKEN="${k3s_token}"
export K3S_NODE_NAME="$(hostname).ec2.internal"

mkdir -p /etc/rancher/k3s

cat << EOF > /etc/rancher/k3s/config.yaml
cluster-init: true
write-kubeconfig-mode: 644
token: $K3S_TOKEN
tls-san:
- $CP_LB_HOST
EOF

curl -sfL https://get.k3s.io | sh -s - server \
  --kubelet-arg="cloud-provider=external" \
  --kubelet-arg="provider-id=aws:///$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"

echo "Waiting for k3s config file to exist.."
while [[ ! -f /etc/rancher/k3s/k3s.yaml ]]; do
  sleep 2
done

echo "Installing cloud controller RBAC"
curl https://raw.githubusercontent.com/andygodish/infrastructure-k3s-aws-terraform/main/manifests/aws-cloud-provider.yaml | kubectl apply -f -

cp /etc/rancher/k3s/k3s.yaml /tmp/k3s.yaml
sed -i -e "s/127.0.0.1/${cp_lb_host}/g" /tmp/k3s.yaml

