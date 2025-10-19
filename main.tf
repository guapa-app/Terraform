# Terraform root module - includes all submodules for Oracle Cloud Infra

module "network" {
  source         = "./network"
  compartment_id = var.compartment_ocid
}

module "oke" {
  source             = "./containers"
  compartment_id     = var.compartment_ocid
  vcn_id             = module.network.vcn_id
  subnet_ids         = module.network.subnet_ids
  service_lb_subnets = module.network.lb_subnet_ids
}

module "database" {
  source         = "./database"
  compartment_id = var.compartment_ocid
  subnet_id      = module.network.db_subnet_id
}

module "storage" {
  source         = "./storage"
  compartment_id = var.compartment_ocid
}

module "iam" {
  source         = "./iam"
  compartment_id = var.compartment_ocid
}


