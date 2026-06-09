variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL"
  type        = string
  default     = "https://PROXMOX_HOST:8006"
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "yggdrasil"
}

variable "datastore_id" {
  description = "Proxmox datastore for VM boot disk"
  type        = string
  default     = "local-zfs"
}

variable "iso_file_id" {
  description = "Proxmox file ID for the OPNsense installer ISO"
  type        = string
  # no default — set iso_file_id in terraform.tfvars
}
