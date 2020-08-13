variable "security_group_name" {type = "list" }
variable "location" { }
variable "resgrp_name" { }


variable "tags" {
  type        = "map"
  default     = {}
}

variable "out_resgrp_name" {
  default = "dummy"
}


resource "null_resource" "security_null" {
  triggers = {
    
    res_name = "${var.out_resgrp_name}"
  }
}

resource "azurerm_network_security_group" "nsg" {
  depends_on = [null_resource.security_null]
  count               = "${length(var.security_group_name)}"
  name                = "${element(var.security_group_name,count.index)}"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"
  security_rule {
    name                       = "Port_3389"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description            = ""
  }
  security_rule {
    name                       = "Port_80"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description            = ""
  }
  tags                = "${var.tags}"
}
