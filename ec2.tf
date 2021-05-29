provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "myTFResourceGroup"
  location = "westus2"
}



resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
	public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

#resource "azurerm_ssh_public_key" "example" {
# name                = "example"
#resource_group_name = "example"
#  location            = "westus2"
#public_key          = file("~/.ssh/id_rsa.pub")
#public_key          = file("C:/Users/girishkh/TF/Ec2/.ssh/id_rsa.pub")
#}

#resource "azurerm_linux_virtual_machine" "example1" {}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_A1_v2"
  admin_username      = "adminuser"
  admin_password      = "Password1234!"

  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]


#admin_ssh_key {
 #   username = "adminuser"
  #  public_key = file ("c:\\users\\girishkh\\.ssh\\id_rsa.pub")
  #}

  #admin_ssh_key {
  #username   = "adminuser"
  #public_key = file("~/.ssh/id_rsa.pub")
  #public_key          = file("C:/Users/girishkh/.ssh/mm")
  # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  # os_profile {
  #  computer_name  = "hostname"
  # admin_username = "adminuser"
  #admin_password = "Password1234!"
  # }
  #os_profile_linux_config {
  # disable_password_authentication = false
  #}
}

output "vmid" {
  value =azurerm_linux_virtual_machine.example.id
  }
