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
  endpoint  = var.proxmox_endpoint
  api_token = data.sops_file.secrets.data["proxmox_api_token"]
  insecure  = true

  ssh {
    agent    = true
    username = "root"
  }
}

resource "proxmox_virtual_environment_vm" "asgard" {
  name        = "asgard"
  description = "OPNsense firewall — WAN on vmbr0, LAN trunk on vmbr1"
  node_name   = var.proxmox_node
  vm_id       = var.vm_id
  tags        = ["homelab", "opnsense", "yggdrasil"]

  on_boot  = true
  started  = true

  cpu {
    cores   = 4
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  # OPNsense is FreeBSD-based; no qemu-guest-agent available
  agent {
    enabled = false
  }

  vga {
    type = "vmware"
  }

  operating_system {
    type = "other"
  }

  # Boot disk — 32 GB on ZFS SSD pool
  disk {
    datastore_id = var.datastore_id
    interface    = "virtio0"
    size         = 32
    file_format  = "raw"
    discard      = "on"
  }

  # OPNsense installer ISO
  cdrom {
    file_id   = var.iso_file_id
    interface = "ide2"
  }

  # Boot from ISO first, then disk
  boot_order = ["ide2", "virtio0"]

  # WAN — bridges to physical NIC → ISP_ROUTER
  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # LAN trunk — internal-only bridge; OPNsense manages internal VLANs on top
  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }
}
