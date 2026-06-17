output "nidavellir_vmid" {
  description = "Proxmox container ID"
  value       = proxmox_virtual_environment_container.nidavellir.vm_id
}

output "nidavellir_ip" {
  description = "Static IP address"
  value       = split("/", var.vm_ip_cidr)[0]
}
