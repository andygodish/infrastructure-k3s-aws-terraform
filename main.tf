provider "aws" {
  region = var.region
}

module "aws_infrastructure" {
  source = "./modules/aws"

  amis            = var.amis
  cluster_name    = var.cluster_name
  is_public       = var.is_public
  k3s_agent_count = var.k3s_agent_count
  os              = var.os
  public_ssh_key  = var.public_ssh_key
  region          = var.region
  tfuser          = var.tfuser
}