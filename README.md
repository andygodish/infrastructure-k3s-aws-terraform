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
```

## K3s Env Vars

