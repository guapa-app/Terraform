output "vcn_id" {
  description = "The OCID of the created VCN"
  value       = module.network.vcn_id
}

output "oke_cluster_id" {
  description = "OKE Cluster OCID"
  value       = module.oke.cluster_id
}

output "oke_kubeconfig" {
  description = "OKE Kubeconfig file"
  value       = module.oke.kubeconfig
  sensitive   = true
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = module.database.endpoint
}

output "bucket_name" {
  description = "Object Storage bucket for backups"
  value       = module.storage.bucket_name
}


