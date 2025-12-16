## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}


variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.0"
}

## Networking placement

variable "use_existing_networking" {
  type        = bool
  description = "Use existing networking resources?"
  default     = false
}
variable "vcn_id" {
  type        = string
  description = "ID of the VCN in which to deploy resources"
  default     = ""
}

variable "endpoint_subnet_id" {
  type        = string
  description = "ID of the public subnet in which to deploy OKE endpoint"
  default     = ""
}

variable "workers_subnet_id" {
  type        = string
  description = "ID of the subnet in which to deploy OKE worker nodes"
  default     = ""
}

variable "services_subnet_id" {
  type        = string
  description = "ID of the subnet in which to deploy OKE services"
  default     = ""
}

variable "mysql_subnet_id" {
  type        = string
  description = "ID of the subnet in which to deploy MySQL DB System (required if use_existing_networking is true)"
  default     = ""
}

variable "network_cidrs" {
  type = map(string)

  default = {
    VCN-CIDR                      = "10.20.0.0/16"
    SUBNET-REGIONAL-CIDR          = "10.20.10.0/24"
    LB-SUBNET-REGIONAL-CIDR       = "10.20.20.0/24"
    ENDPOINT-SUBNET-REGIONAL-CIDR = "10.20.0.0/28"
    MYSQL-SUBNET-REGIONAL-CIDR    = "10.20.30.0/24"
    ALL-CIDR                      = "0.0.0.0/0"
    PODS-CIDR                     = "10.244.0.0/16"
    KUBERNETES-SERVICE-CIDR       = "10.96.0.0/16"
  }
}

## Gitlab runners

variable "gitlab_runner_instances" {
  type        = number
  description = "Number of gitlab instances"
  default     = 1
}

variable "gitlab_runner_namespace" {
  type        = string
  description = "Namespace to use for each instance"
  default     = "default"
}

variable "gitlab_runner_token" {
  type        = string
  description = "Gitlab runner token"
  default     = "gitlab-runner-token"
}


## Autoscaler parameters

variable "min_number_of_nodes" {
  type        = number
  description = "Minimum number of nodes in the node pool"
  default     = 3
}

variable "max_number_of_nodes" {
  type        = number
  description = "Maximum number of nodes in the node pool"
  default     = 10
}

variable "default_autoscaler_image" {
  type        = string
  description = "The default cluster autoscaler image to be used."
  default     = "registry.k8s.io/autoscaling/cluster-autoscaler:v1.32.0"
}

## OKE cluster parameters

variable "cluster_name" {
  type        = string
  description = "Name of OKE cluster"
  default     = "oke-cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "v1.31.1"
}

variable "cluster_type" {
  default = "enhanced"
}

variable "oke_public_endpoint" {
  type        = bool
  description = "Is OKE endpoint public?"
  default     = true
}

variable "is_kubernetes_dashboard_enabled" {
  type        = bool
  description = "Enable OKE dashboard?"
  default     = true
}

## Node pool params

variable "pool_name" {
  type        = string
  description = "Name of workers pool name"
  default     = "node-pool"
}

variable "worker_bv_size" {
  type        = number
  description = "Size of the boot volume"
  default     = 50
}

variable "worker_shape" {
  type        = string
  description = "Worker node shape"
  default     = "VM.Standard.E4.Flex"
}

variable "worker_flex_memory" {
  type        = number
  description = "Worker node memory in GB for flex shape"
  default     = 16
}

variable "worker_flex_ocpu" {
  type        = number
  description = "Worker node number of OCPUs for flex shape"
  default     = 2
}

variable "worker_default_image_name" {
  type        = string
  description = "If no Image ID is supplied, use the most recent Oracle Linux 7.9 Image ID"
  default     = "Oracle-Linux-7.9-2022.+"
}

variable "worker_image_id" {
  type        = string
  description = "ID of a custom Image to use when creating worker nodes"
  default     = ""
}

variable "worker_public_key" {
  type        = string
  description = "Public SSH key for worker node access"
  default     = ""
}

#for mysql
variable "mysql_root_password" {
  description = "MySQL root password"
  type        = string
  sensitive   = true
}

variable "mysql_database" {
  description = "MySQL database name"
  type        = string
  default     = "laravel"
}

variable "mysql_username" {
  description = "MySQL username"
  type        = string
  default     = "laravel_user"
}

variable "mysql_password" {
  description = "MySQL password"
  type        = string
  sensitive   = true
}

variable "mysql_storage_size" {
  description = "MySQL storage size"
  type        = string
  default     = "20Gi"
}

# MySQL DB System variables
variable "mysql_db_system_shape" {
  description = "MySQL DB System shape (e.g., MySQL.2, MySQL.HeatWave.VM.Standard.E3.1.32GB)"
  type        = string
  default     = "MySQL.2"
}

variable "mysql_db_system_configuration_id" {
  description = "MySQL DB System configuration ID (optional)"
  type        = string
  default     = ""
}

variable "mysql_db_system_mysql_version" {
  description = "MySQL version (e.g., 8.0.32, 8.0.33, 8.0.34)"
  type        = string
  default     = "8.0.41"
}

variable "mysql_db_system_data_storage_size_in_gb" {
  description = "MySQL DB System data storage size in GB"
  type        = number
  default     = 100
}

variable "mysql_db_system_hostname_label" {
  description = "MySQL DB System hostname label"
  type        = string
  default     = "mysql-db"
}

variable "mysql_db_system_is_highly_available" {
  description = "Enable high availability for MySQL DB System"
  type        = bool
  default     = false
}

#mysql import dumb

variable "sql_bucket_name" {
  description = "OCI Object Storage bucket name containing SQL dump"
  type        = string
  default     = "bucket-k8s-db"
}

variable "sql_file_name" {
  description = "SQL dump file name in the bucket"
  type        = string
  default     = "guapa_prod.sql"
}


#Laravel container image  mountPath
variable "laravel_replicas_min" {
  description = "Minimum Laravel replicas"
  type        = number
  default     = 2
}

variable "laravel_replicas_max" {
  description = "Maximum Laravel replicas for autoscaling"
  type        = number
  default     = 10
}


####################for SSL

variable "domain_name" {
  description = "Domain name for the Laravel application"
  type        = string
  default     = "guapa.com.sa"
}

variable "cert_email" {
  description = "Email for Let's Encrypt certificate notifications"
  type        = string
  default     = "el3ashe2@gmail.com"
}



variable "enable_monitoring" {
  description = "Enable Prometheus and Grafana monitoring"
  type        = bool
  default     = true
}

variable "enable_ingress" {
  description = "Enable Nginx Ingress controller"
  type        = bool
  default     = true
}

variable "enable_ssl" {
  description = "Enable SSL/TLS with Let's Encrypt"
  type        = bool
  default     = true
}

###################
variable "gitlab_runner_count" {
  type        = number
  default     = 1
  description = "Number of GitLab Runner instances"
}

variable "availability_domain" {
  type        = string
  description = "Availability domain for resources"
}
