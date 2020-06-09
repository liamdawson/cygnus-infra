source "vmware-iso" "vmware-dev" {
  iso_url = "./output/cygnus-hypervisor-amd64.hybrid.iso"

  iso_checksum=""
  iso_checksum_type = "none"

  memory = 2048

  ssh_username = "liamdawson"
  ssh_password = "tmpUserPassword"
  ssh_timeout = "10m"
  shutdown_command = "sudo -S shutdown -P now"

  boot_wait = "5s"
  boot_command = [
    "<enter>"
  ]
}
