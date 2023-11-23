output "vm_data0" {
  value = ["${proxmox_vm_qemu.vm0.*.name}", "${proxmox_vm_qemu.vm0.*.ssh_host}"]
}

output "vm_data1" {
  value = ["${proxmox_vm_qemu.vm1.*.name}", "${proxmox_vm_qemu.vm1.*.ssh_host}"]
}