# mysql.tf - MySQL Database System (OCI Managed MySQL)

# Get MySQL subnet ID and availability domain
locals {
  mysql_subnet_id = var.use_existing_networking ? var.mysql_subnet_id : oci_core_subnet.mysql_subnet[0].id
  # Find availability domain that matches the pattern (e.g., "ME-RIYADH-1-AD-1")
  # The data source returns ADs with the full name format (e.g., "RdGD:ME-RIYADH-1-AD-1")
  mysql_availability_domain = try(
    [
      for ad in data.oci_identity_availability_domains.ads.availability_domains : ad.name
      if can(regex(".*${var.availability_domain}.*", ad.name))
    ][0],
    data.oci_identity_availability_domains.ads.availability_domains[0].name
  )
}

# MySQL DB System
resource "oci_mysql_mysql_db_system" "mysql_db_system" {
  provider            = oci.targetregion
  compartment_id      = var.compartment_ocid
  display_name        = "mysql-db-system-${var.cluster_name}"
  availability_domain  = local.mysql_availability_domain
  shape_name          = var.mysql_db_system_shape
  mysql_version       = var.mysql_db_system_mysql_version
  
  subnet_id = local.mysql_subnet_id
  
  admin_username = "admin"
  admin_password = var.mysql_root_password
  
  data_storage_size_in_gb = var.mysql_db_system_data_storage_size_in_gb
  hostname_label          = var.mysql_db_system_hostname_label
  is_highly_available     = var.mysql_db_system_is_highly_available
  
  configuration_id = var.mysql_db_system_configuration_id != "" ? var.mysql_db_system_configuration_id : null
  
  defined_tags = local.defined_tags
  
  lifecycle {
    ignore_changes = [admin_password]
  }
  
  # Wait for the DB System to be in ACTIVE state before proceeding
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

# Create MySQL secret for Kubernetes (keeping existing secret structure)
resource "local_file" "mysql_secret" {
  content = templatefile("${path.module}/templates/mysql-secret.yaml.tpl", {
    mysql_root_password        = base64encode(var.mysql_root_password)
    mysql_database             = base64encode(var.mysql_database)
    mysql_username             = base64encode(var.mysql_username)
    mysql_password             = base64encode(var.mysql_password)
    mysql_root_password_decoded = var.mysql_root_password
    mysql_database_decoded      = var.mysql_database
    mysql_username_decoded      = var.mysql_username
    mysql_password_decoded      = var.mysql_password
  })
  
  filename             = "./generated/mysql-secret.yaml"
  file_permission      = "0644"
  directory_permission = "0755"
  
  depends_on = [oci_mysql_mysql_db_system.mysql_db_system]
}

# Create MySQL ConfigMap with endpoint
resource "local_file" "mysql_configmap" {
  content = <<-EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  namespace: laravel-prod-ahm
data:
  DB_HOST: "${oci_mysql_mysql_db_system.mysql_db_system.endpoints[0].ip_address}"
  DB_PORT: "3306"
EOT
  
  filename             = "./generated/mysql-configmap.yaml"
  file_permission      = "0644"
  directory_permission = "0755"
  
  depends_on = [oci_mysql_mysql_db_system.mysql_db_system]
}

# Deploy MySQL secret to Kubernetes
resource "null_resource" "deploy_mysql_secret" {
  triggers = {
    manifest_content = local_file.mysql_secret.content
    mysql_endpoint   = oci_mysql_mysql_db_system.mysql_db_system.endpoints[0].ip_address
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "kubectl apply -f ${local_file.mysql_secret.filename}"
  }

  depends_on = [
    null_resource.ensure_cluster_access,
    local_file.mysql_secret,
    oci_mysql_mysql_db_system.mysql_db_system
  ]
}

# Deploy MySQL ConfigMap to Kubernetes
resource "null_resource" "deploy_mysql_configmap" {
  triggers = {
    manifest_content = local_file.mysql_configmap.content
    mysql_endpoint   = oci_mysql_mysql_db_system.mysql_db_system.endpoints[0].ip_address
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "kubectl apply -f ${local_file.mysql_configmap.filename}"
  }

  depends_on = [
    null_resource.ensure_cluster_access,
    local_file.mysql_configmap,
    oci_mysql_mysql_db_system.mysql_db_system
  ]
}

# Note: Database and user creation should be done manually or via a Kubernetes Job
# after the MySQL DB System is provisioned. The MySQL DB System comes with a default
# 'admin' user. You'll need to create the database and application user separately.
