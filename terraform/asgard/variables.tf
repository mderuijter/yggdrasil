variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL (e.g. https://192.168.x.x:8006)"
  type        = string
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
}

variable "vm_id" {
  description = "Proxmox VM ID for the Asgard OPNsense VM"
  type        = number
}
