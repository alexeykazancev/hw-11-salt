output "vm_data" {
  value = ["${proxmox_vm_qemu.vm0.*.name}", "${proxmox_vm_qemu.vm0.*.ssh_host}"]
}

output "vm_data" {
  value = ["${proxmox_vm_qemu.vm1.*.name}", "${proxmox_vm_qemu.vm1.*.ssh_host}"]
}