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
}

# Cluster-level firewall — enables the firewall subsystem and sets the default input policy.
# Phase 1 apply: input_policy = "ACCEPT" (rules load, nothing is dropped yet).
# Phase 2 apply: flip input_policy to "DROP" in terraform.tfvars to enforce the restriction.
resource "proxmox_virtual_environment_cluster_firewall" "cluster" {
  enabled        = true
  ebtables       = false
  input_policy   = var.firewall_input_policy
  output_policy  = "ACCEPT"
  forward_policy = "ACCEPT"
}

# Trusted management source(s) — Seireitei's reserved IP.
# Lives only in terraform.tfvars (gitignored); never appears in committed files.
resource "proxmox_virtual_environment_firewall_ipset" "management" {
  name    = "yggdrasil-mgt"
  comment = "Trusted management sources"

  cidr {
    name    = var.management_source_ip
    comment = "Seireitei"
  }
}

# Named rule set for the Proxmox host — reusable across nodes if the cluster ever expands.
resource "proxmox_virtual_environment_cluster_firewall_security_group" "proxmox_host" {
  name    = "yggdrasil-proxmox"
  comment = "Proxmox host management access"

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Proxmox web UI"
    source  = "+yggdrasil-mgt"
    dport   = "8006"
    proto   = "tcp"
    log     = "nolog"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "SSH"
    source  = "+yggdrasil-mgt"
    dport   = "22"
    proto   = "tcp"
    log     = "nolog"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "SPICE console proxy"
    source  = "+yggdrasil-mgt"
    dport   = "3128"
    proto   = "tcp"
    log     = "nolog"
  }

  depends_on = [proxmox_virtual_environment_firewall_ipset.management]
}

# Enable the host firewall on the Proxmox node itself.
resource "proxmox_node_firewall" "host" {
  node_name = var.proxmox_node
  enabled   = true

  depends_on = [proxmox_virtual_environment_cluster_firewall.cluster]
}

# Apply the yggdrasil-proxmox security group to the Proxmox host node.
resource "proxmox_virtual_environment_firewall_rules" "host" {
  node_name = var.proxmox_node

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.proxmox_host.name
    comment        = "Apply yggdrasil-proxmox security group"
  }

  depends_on = [
    proxmox_node_firewall.host,
    proxmox_virtual_environment_cluster_firewall_security_group.proxmox_host,
  ]
}
