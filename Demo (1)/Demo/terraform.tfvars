# Resource group variables

resource_grp_name           = "Telia"
location              = "East US"
env                   = "DEV"
vnet_name             = ["vnet1", "vnet2"]
cidr_public           = ["14.0.0.0/16","10.0.0.0/16"]
subnet_name           = ["subnet1", "subnet2"]
subnet_public         = ["14.0.1.0/24","14.0.3.0/24"]
subnet_private        = ["10.0.2.0/24","10.0.3.0/24"]

# Variables for security group

security_group_name = ["Mspaudit-DEV", "Mspaudit-PROD","Mspaudit-MGMT"]
tags                = {
  Environment         = "qa"
  Application         = "demo"
  BusinessOwner       = "MSAudit"
}

