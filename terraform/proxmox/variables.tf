variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL (e.g. https://192.168.x.x:8006)"
  type        = string
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "yggdrasil"
}

variable "management_source_ip" {
  description = "IP/CIDR allowed to reach Proxmox management ports (22, 8006, 3128) — added to the yggdrasil-mgt IPSet"
  type        = string
}

variable "firewall_input_policy" {
  description = "Default input policy for the cluster firewall. Use ACCEPT on first apply to verify rules, then switch to DROP."
  type        = string
  default     = "ACCEPT"

  validation {
    condition     = contains(["ACCEPT", "DROP", "REJECT"], var.firewall_input_policy)
    error_message = "Must be ACCEPT, DROP, or REJECT."
  }
}
