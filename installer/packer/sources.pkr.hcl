source "vmware-iso" "vmware-dev" {
  iso_url = "./output/cygnus-aio.iso"
  iso_checksum="none"

  memory = 2048

  ssh_username = "kubeadmin"
  ssh_password = "tmpUserPassword"
  ssh_timeout = "10m"
  shutdown_command = "sudo -S shutdown -P now"

  boot_wait = "5s"
  boot_command = [
    "<esc>",
    "/install.amd/vmlinuz initrd=/install.amd/initrd.gz ",
    "auto ",
    "<enter>"
  ]
}
