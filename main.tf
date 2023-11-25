resource "proxmox_vm_qemu" "salt-server" {
  count       = var.vm_count
  name        = "salt-server-${count.index}"
  desc        = "VM salt-server-${count.index}"
  target_node = var.pm_target_node_name

  kvm = true

  clone    = var.vm_template
  cpu      = "host"
  numa     = false
  cores    = 2
  sockets  = 1
  memory   = 2048
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  network {
    #id        = 0
    model     = "virtio"
    bridge    = var.vm_bridge
    firewall  = false
    link_down = false
  }

  disk {
      #id           = 1 # 0 - already exists in template OS
      size         = "10G"
      type         = "virtio"
      storage      = "local-lvm"
      #storage_type = "lvmthin"
      iothread     = 1
      discard      = "ignore"
  }

  force_create = false
  full_clone   = true

  os_type = "cloud-init"
  ciuser  = var.ci_user
  sshkeys = file(var.ci_ssh_public_keys_file)

  nameserver   = var.vm_ip_dns
  searchdomain = var.vm_searchdomain
  ipconfig0    = "ip=${var.vm_ip_network}${count.index + var.vm_ip_network_start}/${var.vm_ip_cidr},gw=${var.vm_ip_gateway}"

  agent   = 1
  balloon = 0
  onboot  = false

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = self.default_ipv4_address
  }

  provisioner "remote-exec" {
        
    inline = [
      "export http_proxy=http://192.168.152.9:3128",
      "export https_proxy=http://192.168.152.9:3128",
      "mkdir /etc/apt/keyrings",
      "apt update",
      "apt install -y curl wget mc sudo atop htop",
      "curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://repo.saltproject.io/salt/py3/debian/11/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg",
      "echo deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://repo.saltproject.io/salt/py3/debian/11/amd64/latest bullseye main | tee /etc/apt/sources.list.d/salt.list",
      "apt update",
      "apt install -y salt-master salt-ssh salt-syndic salt-cloud salt-api",
      "echo interface: 10.128.64.162 | tee -a /etc/salt/master",
      "systemctl enable salt-master && systemctl start salt-master",
      "systemctl enable salt-syndic && systemctl start salt-syndic",
      "systemctl enable salt-api && systemctl start salt-api",
    ]
  }
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}


resource "proxmox_vm_qemu" "salt-minion" {
  count       = var.vm_count
  name        = "salt-minion-${count.index}"
  desc        = "VM salt-minion-${count.index}"
  target_node = var.pm_target_node_name

  kvm = true

  clone    = var.vm_template
  cpu      = "host"
  numa     = false
  cores    = 2
  sockets  = 1
  memory   = 2048
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  network {
    #id        = 0
    model     = "virtio"
    bridge    = var.vm_bridge
    firewall  = false
    link_down = false
  }

  disk {
      #id           = 1 # 0 - already exists in template OS
      size         = "10G"
      type         = "virtio"
      storage      = "local-lvm"
      #storage_type = "lvmthin"
      iothread     = 1
      discard      = "ignore"
  }

  force_create = false
  full_clone   = true

  os_type = "cloud-init"
  ciuser  = var.ci_user
  sshkeys = file(var.ci_ssh_public_keys_file)

  nameserver   = var.vm_ip_dns
  searchdomain = var.vm_searchdomain
  ipconfig0    = "ip=${var.vm_ip_network}${count.index + 1 + var.vm_ip_network_start}/${var.vm_ip_cidr},gw=${var.vm_ip_gateway}"

  agent   = 1
  balloon = 0
  onboot  = false

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = self.default_ipv4_address
  }
  
  provisioner "remote-exec" {
        
    inline = [
      "export http_proxy=http://192.168.152.9:3128",
      "export https_proxy=http://192.168.152.9:3128",
      "mkdir /etc/apt/keyrings",
      "apt update",
      "apt install -y curl wget mc sudo atop htop",
      "curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://repo.saltproject.io/salt/py3/debian/11/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg",
      "echo deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://repo.saltproject.io/salt/py3/debian/11/amd64/latest bullseye main | tee /etc/apt/sources.list.d/salt.list",
      "apt update",
      "apt install -y salt-minion salt-ssh",
      "echo minion-0 | tee -a /etc/salt/minion_id",
      "systemctl enable salt-minion && systemctl start salt-minion",
    ]
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}
