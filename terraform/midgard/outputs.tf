output "midgard_vmid" {
  description = "Proxmox VM ID"
  value       = proxmox_virtual_environment_vm.midgard.vm_id
}

output "midgard_ip" {
  description = "Static IP address"
  value       = split("/", var.vm_ip_cidr)[0]
}
