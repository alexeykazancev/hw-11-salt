output "vm_data0" {
  value = ["${proxmox_vm_qemu.salt-server.*.name}", "${proxmox_vm_qemu.salt-server.*.ssh_host}"]
}

output "vm_data1" {
  value = ["${proxmox_vm_qemu.salt-minion.*.name}", "${proxmox_vm_qemu.salt-minion.*.ssh_host}"]
}