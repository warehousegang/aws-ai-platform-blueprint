############################################################
# VPC Module
############################################################
module "vpc" {
  source = "./modules/vpc"

  aws_region   = var.aws_region
  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
}

############################################################
# EKS Module
############################################################
module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  aws_region      = var.aws_region

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

############################################################
# Observability Module
############################################################
module "observability" {
  source = "./modules/observability"

  namespace = "observability"
}
