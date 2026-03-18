# 1. Настройка провайдеров
terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# 2. Переменные
variable "vsphere_user" {}
variable "vsphere_password" {}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = "192.168.31.12"
  allow_unverified_ssl = true
}

# 3. Данные
data "vsphere_datacenter" "dc" { name = "ha-datacenter" }
data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_resource_pool" "pool" {
  name          = "Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 4. Копирование диска силами самого ESXi через SSH
resource "null_resource" "copy_vmdk" {
  connection {
    type     = "ssh"
    user     = "root"
    password = var.vsphere_password
    host     = "192.168.31.12"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /vmfs/volumes/datastore1/k8s-worker-3",
      "vmkfstools -i /vmfs/volumes/datastore1/ubuntu-template-base/ubuntu-template-base.vmdk -d thin /vmfs/volumes/datastore1/k8s-worker-3/k8s-worker-3.vmdk"
    ]
  }
}

# 5. Виртуальная машина
resource "vsphere_virtual_machine" "k8s_worker_3" {
  name             = "k8s-worker-3"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 2048
  guest_id = "ubuntu64Guest"

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label        = "disk0"
    # Указываем путь к файлу, который создаст vmkfstools
    path         = "k8s-worker-3/k8s-worker-3.vmdk"
    attach       = true
    datastore_id = data.vsphere_datastore.datastore.id
  }

  # Ждем, пока vmkfstools закончит копирование
  depends_on = [null_resource.copy_vmdk]
}
