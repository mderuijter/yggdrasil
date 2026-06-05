output "muspelheim_vmid" {
  description = "Proxmox VM ID"
  value       = proxmox_virtual_environment_vm.muspelheim.vm_id
}

output "muspelheim_ip" {
  description = "Static IP on lab VLAN"
  value       = "MUSPELHEIM_IP"
}
