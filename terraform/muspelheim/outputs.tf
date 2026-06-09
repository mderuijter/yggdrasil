output "muspelheim_vmid" {
  description = "Proxmox VM ID"
  value       = proxmox_virtual_environment_vm.muspelheim.vm_id
}

output "muspelheim_ip" {
  description = "Static IP address"
  value       = split("/", var.vm_ip_cidr)[0]
}
