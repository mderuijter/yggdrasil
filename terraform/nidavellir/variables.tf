variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL (e.g. https://192.168.x.x:8006)"
  type        = string
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "yggdrasil"
}

variable "vm_id" {
  description = "Proxmox container ID"
  type        = number
}

variable "datastore_id" {
  description = "Proxmox datastore for container rootfs (ZFS SSD pool)"
  type        = string
  default     = "local-zfs"
}

variable "lxc_template_url" {
  description = "URL to Ubuntu 24.04 LXC root filesystem tarball (vztmpl)"
  type        = string
}

variable "vm_ip_cidr" {
  description = "Static IP address with CIDR prefix (e.g. 10.x.x.x/24)"
  type        = string
}

variable "vm_gateway" {
  description = "Default gateway for the container"
  type        = string
}

variable "vm_vlan_id" {
  description = "VLAN tag for the container network interface"
  type        = number
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 4096
}

variable "disk_size_gb" {
  description = "Root filesystem size in GB"
  type        = number
  default     = 32
}
