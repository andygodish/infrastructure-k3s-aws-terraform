# infrastructure-k3s-aws-terraform

Terraform script designed to quickly stand up a k3s cluster.

First iteration creates a single vpc with two public subnets.

## Quick Commands

```
# terraform

terraform apply -var-file=terraform.tfvars --auto-approve
terraform destroy -var-file=terraform.tfvars --auto-approve

# k3s configuration

export PATH=/var/libe/rancher/k3s/bin:$PATH
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
alias k=kubectl

# retrieve kubeconfig

scp k3s-init-server:/tmp/k3s.yaml ~/.kube/config
```

## AWS External Cloud Controller Manager

See init_server_userdata.sh under templates and note the kubectl apply command. For some reason, new version of the container image cause the pods to crashloop. The older version appears to work with at least kubernetes 1.21.7. You'll need to test additional versions.

When using the external aws cloud controller, for some reason the 

