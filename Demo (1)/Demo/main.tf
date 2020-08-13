variable "location"          { }
variable "resource_grp_name" { }
variable "env"               { }
variable "subnet_name"       { }
variable "subnet_public"     { }
variable "subnet_private"  { }
variable "vnet_name" {
  #type = list(string)
 }
variable "cidr_public" { }
variable "security_group_name" { }

provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=2.0.0"
  skip_provider_registration = "true"
   features {}

}

terraform {
   backend "azure" {} 
   }

variable "tags" {
  type        = "map"
  default     = {}
}

#storage account vars
variable "storage_account_name" {
  description = "The name for the storage account"
  default     = ""
}
variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium"
  default     = ""
}
variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS and ZRS"
  default     = ""
}
variable "account_kind" {
  description = "Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2"
  default     = ""
}
variable "access_tier" {
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot"
  default     = ""
}

module "resource_grp" {
  source = "./resource_grp"

  resource_grp_name = "${var.resource_grp_name}"
  location = "${var.location}"
  tags = "${var.tags}"
}



module "network" {
  source          = "./network"
  resgrp_name     = "${module.resource_grp.out_resgrp_name}"
  location        = "${var.location}"
  env = "${var.env}"
  cidr_public = "${var.cidr_public}"
  subnet_name = "${var.subnet_name}"
  subnet_public ="${var.subnet_public}"
  subnet_private = "${var.subnet_private}"
  vnet_name = "${var.vnet_name}"

  
}

module "security_grp" {
  source              = "./security_grp"
  security_group_name = "${var.security_group_name}"
  location            = "${var.location}"
  resgrp_name         = "${var.resource_grp_name}"
  #subnet_names        = "${var.subnet_names}"
  #vnet_name           = "${var.vnet_name}"
  #subnet_prefixes     = "${var.subnet_prefixes}"
  tags                = "${var.tags}"
  out_resgrp_name     = "${module.resource_grp.out_resgrp_name}"
  #out_subnet_id       = "${module.network.out_subnet_id}"
}

module "compute_linux" {
  source               = "./compute_linux"
  pub_subnet           = "${module.network.out_subnet_id}"
  resgrp_name          = "${module.resource_grp.out_resgrp_name}"
  location             = "${var.location}"
  #nb_instances        = "${var.nb_instances}"
  #lb_nat_rule_id       = "${module.load_balancer.lb_nat_rule_id}"
  #lb_backend_pool_id   = "${module.load_balancer.lb_backend_pool_id}"
  #availability_set_id  = "${module.availability_set.availability_set_id}"
  #out_subnet_id        = "${module.network.out_subnet_id}"
}
