output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.eks.kubeconfig
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks.config_map_aws_auth
}

output "region" {
  description = "AWS region."
  value       = var.region
}

output "db_admin_username" {
  description = "Admin db username"
  value       = module.db.this_rds_cluster_master_username
}

output "db_admin_password" {
  description = "Admin db password"
  value       = module.db.this_rds_cluster_master_password
}

output "db_cluster_endpoint" {
  description = "DB hostname"
  value       = module.db.this_rds_cluster_endpoint
}

output "db_cluster_port" {
  description = "DB port"
  value       = module.db.this_rds_cluster_port
}
