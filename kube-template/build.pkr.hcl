build {
  sources = [
    "source.proxmox.kube-template"
  ]

  provisioner "shell" {
    inline = [
      "sudo sed -iEe 's/lock_passwd: False/lock_passwd: True/' /etc/cloud/cloud.cfg.d/10_user.cfg",
      "sudo cloud-init clean",
      "sudo rm /etc/sudoers.d/ubuntu"
    ]
  }
}
