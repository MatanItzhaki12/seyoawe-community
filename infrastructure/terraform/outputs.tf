output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "kubeconfig_update_command" {
  description = "Run this command to update local kubeconfig for the created cluster."
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.this.name} --region ${var.aws_region}"
}
