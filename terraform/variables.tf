variable "aws_region" {
  type        = string
  default     = "us-east-2"
  description = "AWS region for deployment"
}

variable "cluster_name" {
  type        = string
  default     = "observability-eks"
  description = "EKS cluster name"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.10.0.0/16"
  description = "VPC CIDR block"
}

variable "public_subnets" {
  type = list(string)
  default = [
    "10.10.1.0/24",
    "10.10.2.0/24",
    "10.10.3.0/24",
  ]
  description = "Public subnet CIDR blocks"
}

variable "private_subnets" {
  type = list(string)
  default = [
    "10.10.11.0/24",
    "10.10.12.0/24",
    "10.10.13.0/24",
  ]
  description = "Private subnet CIDR blocks"
}

