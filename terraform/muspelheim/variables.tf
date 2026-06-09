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
  description = "Proxmox datastore for VM disks"
  type        = string
  default     = "local-zfs"
}

