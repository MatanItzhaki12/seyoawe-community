variable "aws_region" {
  description = "AWS region for all infrastructure."
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "seyoawe-eks"
}

variable "eks_version" {
  description = "Kubernetes version for the EKS control plane. Keep on a version in standard support to avoid the $0.60/hour extended-support fee."
  type        = string
  default     = "1.33"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets. Nodes run here to avoid the NAT Gateway cost."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "node_instance_types" {
  description = "EC2 instance types used by the EKS managed node group. Two similar types improve SPOT availability."
  type        = list(string)
  default     = ["t3.small", "t3a.small"]
}

variable "node_capacity_type" {
  description = "EC2 purchase mode for worker nodes. Allowed: ON_DEMAND, SPOT. Use SPOT for ~70% savings on non-production clusters."
  type        = string
  default     = "SPOT"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes. 3 gives us ~24 pod slots on t3.small (8 per node), which fits kube-system + Dashboard + Kong + the seyoawe workload with headroom."
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}
