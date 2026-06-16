terraform {
  required_version = ">= 1.5"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.60"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

data "sops_file" "secrets" {
  source_file = "${path.module}/secrets.enc.yaml"
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = "root@pam"
  password = data.sops_file.secrets.data["proxmox_password"]
  insecure = true

  ssh {
    agent    = true
    username = "root"
  }
}

resource "proxmox_download_file" "ubuntu_2404_cloud" {
  content_type        = "iso"
  datastore_id        = "local"
  node_name           = var.proxmox_node
  url                 = "https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img"
  overwrite           = false
  overwrite_unmanaged = true
}

resource "proxmox_virtual_environment_vm" "midgard" {
  name        = "midgard"
  description = "K3s cluster — ArgoCD, portfolio services"
  node_name   = var.proxmox_node
  vm_id       = var.vm_id
  tags        = ["k3s", "homelab", "yggdrasil"]

  on_boot = true
  started = true

  machine = "q35"
  bios    = "ovmf"

  cpu {
    cores   = 4
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 8192
  }

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  # Required for OVMF/q35 — must be created before the boot disk
  efi_disk {
    datastore_id      = var.datastore_id
    file_format       = "raw"
    type              = "4m"
    pre_enrolled_keys = false
  }

  # Boot disk — OS only
  disk {
    datastore_id = var.datastore_id
    file_id      = proxmox_download_file.ubuntu_2404_cloud.id
    interface    = "virtio0"
    size         = 50
    file_format  = "raw"
    discard      = "on"
  }

  # Intel 660p NVMe raw disk passthrough for dedicated etcd storage.
  # PCIe passthrough (hostpci) fails on this device due to an intrinsic MSI-X
  # table/PBA layout issue in the 660p's config space. Raw passthrough via
  # virtio-blk avoids VFIO entirely and satisfies the same requirement.
  # Appears as /dev/vdb inside the VM — partitioned and formatted by Ansible.
  disk {
    datastore_id      = ""
    path_in_datastore = var.nvme_disk_path
    interface         = "virtio1"
    file_format       = "raw"
  }

  # Internal VLAN trunk — routed by OPNsense
  network_device {
    bridge  = "vmbr1"
    model   = "virtio"
    vlan_id = var.vm_vlan_id
  }

  initialization {
    datastore_id = var.datastore_id

    ip_config {
      ipv4 {
        address = var.vm_ip_cidr
        gateway = var.vm_gateway
      }
    }

    dns {
      servers = [var.vm_gateway]
    }

    user_account {
      keys     = [data.sops_file.secrets.data["ssh_public_key"]]
      username = "ubuntu"
    }
  }

  boot_order = ["virtio0"]
}
