variable "vnet_name"     {
 #type = list(string)
 }  
variable "location"      { }
variable "resgrp_name"   { }
variable "env"           { }
variable "cidr_public"   { }
variable "subnet_name"   {
  #type = list(string)
 }
variable "subnet_public" { }
variable "subnet_private" { }
variable "natprivateIPAddress" { 
  default = "10.0.2.8"
}

resource "azurerm_virtual_network" "vnet" {
 count               = "${length(var.vnet_name)}"
 name                = "${element(var.vnet_name,count.index)}"
 location            = "${var.location}"
 address_space       = ["${element(var.cidr_public,count.index)}"]
 resource_group_name = "${var.resgrp_name}"

  tags = {
     Name        = "${format("sv-u-convey-static-%d", count.index)}"
     Environment = "${format("%s", upper(var.env))}"
}
}

resource "azurerm_subnet" "subnet-public" {
 count                = "${length(var.subnet_name)}"
 name                 = "${element(var.subnet_name,count.index)}"
 virtual_network_name = "${azurerm_virtual_network.vnet[0].name}"
 address_prefix       = "${element(var.subnet_public,count.index)}"
 resource_group_name  = "${var.resgrp_name}" 

}

resource "azurerm_subnet" "subnet-private" {
 count                = "${length(var.subnet_name)}"
 name                 = "${element(var.subnet_name,count.index)}"
 virtual_network_name = "${azurerm_virtual_network.vnet[1].name}"
 address_prefix       = "${element(var.subnet_private,count.index)}"
 resource_group_name  = "${var.resgrp_name}" 

}

resource "azurerm_route_table" "routetable1" {
  name                = "routetable1"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"
}

resource "azurerm_route" "route1" {
  name                ="route1"
  resource_group_name = "${var.resgrp_name}"
  route_table_name    = "${azurerm_route_table.routetable1.name}"
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"

}

resource "azurerm_route_table" "routetable2" {
  name                = "routetable2"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"
}

resource "azurerm_route" "route2" {
  name                ="route2"
  resource_group_name = "${var.resgrp_name}"
  route_table_name    = "${azurerm_route_table.routetable2.name}"
  address_prefix      = "10.0.1.0/24"
  next_hop_type       = "VirtualAppliance"
next_hop_in_ip_address = "${var.natprivateIPAddress}"
}

resource "azurerm_subnet_route_table_association" "public" {
  count = "${length(var.subnet_name)}"
  subnet_id      = "${azurerm_subnet.subnet-public[count.index].id}"
  route_table_id = "${azurerm_route_table.routetable1.id}"
}
resource "azurerm_subnet_route_table_association" "private" {
  count = "${length(var.subnet_name)}"
  subnet_id      = "${azurerm_subnet.subnet-private[count.index].id}"
  route_table_id = "${azurerm_route_table.routetable2.id}"
}

resource "azurerm_virtual_network_peering" "peer1" {
  count                     = "${length(var.vnet_name)}"
  name                      = "peer1to2"
  resource_group_name       = "${var.resgrp_name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet[0].name}"
  remote_virtual_network_id = "${azurerm_virtual_network.vnet[1].id}"
}

resource "azurerm_virtual_network_peering" "peer2" {
  count                     = "${length(var.vnet_name)}"
  name                      = "peer2to1"
  resource_group_name       = "${var.resgrp_name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet[1].name}"
  remote_virtual_network_id = "${azurerm_virtual_network.vnet[0].id}"
}

output "out_subnet_id" {
  value = azurerm_subnet.subnet-public[0].id
}
/*
output "out_subnet_id" {
  value = azurerm_subnet.subnet-private[0].id
}*/