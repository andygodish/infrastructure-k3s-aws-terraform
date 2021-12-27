
variable "amis" {
  type = map(map(object({
    ami  = string
    user = string
  })))
}

variable "cidr_public_subnet_1" {
  type    = string
  default = "10.0.11.0/24"
}

variable "cidr_public_subnet_2" {
  type    = string
  default = "10.0.12.0/24"
}

variable "cidr_vpc" {
  type    = string
  default = "10.0.0.0/16"
}

variable "cluster_name" {
  type = string
}

variable "is_public" {
    type = bool
}
variable "k3s_agent_count" {
  type = number
  default = 3
}
variable "k3s_agent_size" {
  type    = string
  default = "t2.xlarge"
}
variable "k3s_server_size" {
  type    = string
  default = "t2.xlarge"
}


variable "os" {
  type        = string
  description = "AWS AMI OS"
}
  
variable "public_ssh_key" {
  type = string
}

variable "region" {
  type    = string
}

variable "tfuser"{
  type = string
}
