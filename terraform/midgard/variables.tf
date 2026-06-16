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
  description = "Proxmox datastore for VM boot disk (ZFS SSD pool — not etcd)"
  type        = string
  default     = "local-zfs"
}

variable "vm_id" {
  description = "Proxmox VM ID for the Midgard K3s VM"
  type        = number
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

variable "nvme_disk_path" {
  description = "Stable by-id path to the Intel 660p NVMe on the Proxmox host for etcd raw disk passthrough"
  type        = string
}
