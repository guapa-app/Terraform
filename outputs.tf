## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "cluster_instruction" {
value = <<EOT
1.  Open OCI Cloud Shell.
2.  Execute below command to setup OKE cluster access:
$ oci ce cluster create-kubeconfig --region ${var.region} --cluster-id ${module.oci-oke.cluster.id}
3.  List gitlab runner deployments:
$ kubectl get deployments --namespace ${var.gitlab_runner_namespace}
EOT
}

output "cluster_context_setup" {
    value = "oci ce cluster create-kubeconfig --region ${var.region} --cluster-id ${module.oci-oke.cluster.id}"
}

output "list_gr_deployments" {
    value = "kubectl get deployments --namespace ${var.gitlab_runner_namespace}"
}

output "mysql_db_system_endpoint" {
  description = "MySQL DB System endpoint IP address"
  value       = oci_mysql_mysql_db_system.mysql_db_system.endpoints[0].ip_address
}

output "mysql_db_system_id" {
  description = "MySQL DB System OCID"
  value       = oci_mysql_mysql_db_system.mysql_db_system.id
}

output "mysql_connection_info" {
  description = "MySQL connection information"
  value = {
    host     = oci_mysql_mysql_db_system.mysql_db_system.endpoints[0].ip_address
    port     = 3306
    database = var.mysql_database
    username = var.mysql_username
  }
  sensitive = true
}