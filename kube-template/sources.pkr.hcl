source "proxmox" "kube-template" {
  proxmox_url = "https://swan.home.ldaws.net:8006/api2/json"
  # TODO: request API token support (or add it)
  username = "packer@pve"
  node = "swan"

  cores = 2
  memory = 2048
  os = "l26"

  network_adapters {
    bridge = "vmbr0"
    model = "virtio"
  }

  disks {
    type = "virtio"
    disk_size = "32G"
    storage_pool = "local-lvm"
    storage_pool_type = "lvm"
  }

  # requires manual download
  iso_file = "local:iso/debian-10.4.0-amd64-netinst.iso"
  iso_checksum="ec69e4bfceca56222e6e81766bf235596171afe19d47c20120783c1644f72dc605d341714751341051518b0b322d6c84e9de997815e0c74f525c66f9d9eb4295"

  http_directory = "http"
  ssh_username = "ubuntu"
  ssh_timeout = "10m"
  ssh_password = "packer"
  unmount_iso = true
  template_name = "kube-template"
  template_description = "TODO"


  boot_wait = "10s"
  boot_command = [
    "<esc><wait>",
    "install <wait>",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/./preseed.cfg <wait>",
    "debian-installer=en_US.UTF-8 <wait>",
    "auto <wait>",
    "locale=en_AU.UTF-8 <wait>",
    "kbd-chooser/method=us <wait>",
    "keyboard-configuration/xkb-keymap=us <wait>",
    "netcfg/get_hostname=kubetemplate <wait>",
    "netcfg/get_domain=home.ldaws.net <wait>",
    "fb=false <wait>",
    "debconf/frontend=noninteractive <wait>",
    "console-setup/ask_detect=false <wait>",
    "console-keymaps-at/keymap=us <wait>",
    "grub-installer/bootdev=/dev/vda <wait>",
    "<enter><wait>"
  ]
#    "console=ttyS0,115200 <wait>",

  cloud_init = true
  onboot = true
}
