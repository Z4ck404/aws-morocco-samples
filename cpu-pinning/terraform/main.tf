terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "cern-inspired-cluster"
}

variable "kubernetes_version" {
  type    = string
  default = "1.31"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.15.1"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # Optional but common for first bring-up
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    high_perf = {
      name = "high-perf-ng"

      instance_types = ["c5.2xlarge"]

      min_size     = 2
      max_size     = 5
      desired_size = 2

      ami_type = "AL2023_x86_64_STANDARD"

      # This is the key piece: nodeadm NodeConfig that sets kubelet config
      cloudinit_pre_nodeadm = [
        {
          content_type = "application/node.eks.aws"
          content = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              kubelet:
                config:
                  cpuManagerPolicy: static
                  systemReserved:
                    cpu: "300m"
                    memory: "300Mi"
                  kubeReserved:
                    cpu: "300m"
                    memory: "300Mi"
          EOT
        }
      ]
    }
  }

  tags = {
    Terraform = "true"
  }
}
