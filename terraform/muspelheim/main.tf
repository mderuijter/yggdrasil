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
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = "https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img"
  overwrite    = false
}

resource "proxmox_virtual_environment_vm" "muspelheim" {
  name        = "muspelheim"
  description = "AI VM — Ollama + Open WebUI, GPU PCIe passthrough"
  node_name   = var.proxmox_node
  vm_id       = var.vm_id
  tags        = ["ai", "homelab", "yggdrasil"]

  on_boot = true
  started = true

  # q35 machine + OVMF required for PCIe passthrough
  machine = "q35"
  bios    = "ovmf"

  cpu {
    cores   = 8
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 16384
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

  # Boot disk — expanded from Ubuntu 24.04 minimal cloud image
  disk {
    datastore_id = var.datastore_id
    file_id      = proxmox_download_file.ubuntu_2404_cloud.id
    interface    = "virtio0"
    size         = 100
    file_format  = "raw"
    discard      = "on"
  }

  # GPU PCIe passthrough — both GPU and HDMI audio functions passed as a group.
  # Both functions passed as a group; x_vga required for display init
  # xvga intentionally omitted — GPU is for CUDA compute only, not display.
  # OVMF hangs initialising the GPU GOP when xvga=true on a headless VM.
  hostpci {
    device = "hostpci0"
    id     = "GPU_PCI_ID"
    pcie   = true
    rombar = true
  }

  # Lab VLAN (AI/Lab — LAB_VLAN_SUBNET) — internal trunk, routed by OPNsense
  network_device {
    bridge  = "vmbr1"
    model   = "virtio"
    vlan_id = 0
  }

  initialization {
    datastore_id = var.datastore_id

    ip_config {
      ipv4 {
        address = "MUSPELHEIM_IP/24"
        gateway = "MUSPELHEIM_GATEWAY"
      }
    }

    dns {
      servers = ["MUSPELHEIM_GATEWAY"]
    }

    user_account {
      keys     = [data.sops_file.secrets.data["ssh_public_key"]]
      username = "ubuntu"
    }
  }

  boot_order = ["virtio0"]
}
