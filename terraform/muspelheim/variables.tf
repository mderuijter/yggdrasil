variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL"
  type        = string
  default     = "https://PROXMOX_HOST:8006"
}

variable "proxmox_password" {
  description = "root@pam password — required for hostpci passthrough (Proxmox root-only restriction)"
  type        = string
  sensitive   = true
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

variable "ssh_public_key" {
  description = "SSH public key for the ubuntu user on Muspelheim"
  type        = string
}
