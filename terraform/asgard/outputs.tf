output "vm_id" {
  description = "Proxmox VM ID for Asgard"
  value       = proxmox_virtual_environment_vm.asgard.vm_id
}

output "vm_name" {
  description = "VM name"
  value       = proxmox_virtual_environment_vm.asgard.name
}
