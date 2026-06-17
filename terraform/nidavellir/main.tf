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

resource "proxmox_download_file" "ubuntu_2404_lxc" {
  content_type        = "vztmpl"
  datastore_id        = "local"
  node_name           = var.proxmox_node
  url                 = var.lxc_template_url
  overwrite           = false
  overwrite_unmanaged = true
}

resource "proxmox_virtual_environment_container" "nidavellir" {
  description  = "Kafka + PostgreSQL — event streaming and storage for portfolio services"
  node_name    = var.proxmox_node
  vm_id        = var.vm_id
  tags         = ["homelab", "kafka", "postgres", "yggdrasil"]

  unprivileged = true
  features {
    nesting = true
  }

  started = true

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores = var.cpu_cores
  }

  memory {
    dedicated = var.memory_mb
    swap      = 0
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size_gb
  }

  initialization {
    hostname = "nidavellir"

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
      keys = [data.sops_file.secrets.data["ssh_public_key"]]
    }
  }

  network_interface {
    name    = "veth0"
    bridge  = "vmbr1"
    vlan_id = var.vm_vlan_id
  }

  operating_system {
    template_file_id = proxmox_download_file.ubuntu_2404_lxc.id
    type             = "ubuntu"
  }
}
