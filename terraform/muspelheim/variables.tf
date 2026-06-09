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
  description = "Proxmox datastore for VM disks"
  type        = string
  default     = "local-zfs"
}

variable "vm_ip_cidr" {
  description = "Static IP address with CIDR prefix (e.g. 10.x.x.x/24)"
  type        = string
}

variable "vm_gateway" {
  description = "Default gateway for the VM"
  type        = string
}

variable "vm_vlan_id" {
  description = "VLAN ID for the VM network interface"
  type        = number
}

variable "gpu_pci_id" {
  description = "PCI ID of the GPU to pass through (e.g. 0000:XX:00)"
  type        = string
}

