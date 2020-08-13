variable "location"      { }
variable "resgrp_name"   { }
variable "pub_subnet" {}
resource "azurerm_network_interface" "main" {
  name                = "VM-nic"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${var.pub_subnet}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "demo-vm"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_A1"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}