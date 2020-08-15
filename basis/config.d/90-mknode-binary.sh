#!/usr/bin/env bash

set -eu

main() {
  cat <<'EOMKNODEBINARY' > /usr/local/bin/cygnus-mknode
#!/usr/bin/env bash

set -eu

if [ $# -ne 1 ]; then
  echo "usage: $0 <node name>"
  exit 1
fi

node_name="$1"
node_fqdn="${node_name}.home.ldaws.net"
node_vol="cygnus-${node_name}"

# Adapted from https://serverfault.com/a/299563/183335
# According to man virt-install, mac should start with 52:54:00:
node_mac="$(echo "$node_fqdn" | md5sum | sed 's/^\(..\)\(..\)\(..\).*$/52:54:00:\1:\2:\3/')"

if ! virsh vol-info --pool=host --name="$node_vol" >/dev/null 2>&1; then
  virsh vol-create-as --pool=host --name="${node_vol}" --capacity=32G --format=raw
  virsh vol-upload --pool=host --vol="${node_vol}" --file=/var/lib/machines/focal-server-cloudimg-amd64.raw
fi

virt-install \
  --sysinfo="system.serial=ds=nocloud-net;h=${node_fqdn};s=http://swan.home.ldaws.net:5000/" \
  --name="$node_name" \
  --memory=2048 \
  --vcpus=2 \
  --cpu=host \
  --import --disk="vol=host/${node_vol},bus=virtio,cache=none" \
  --os-variant=ubuntu20.04 \
  --network="bridge=brlan,model=virtio,mac=${node_mac}" \
  --noautoconsole \
  --console pty,target_type=serial

EOMKNODEBINARY
  chmod +x /usr/local/bin/cygnus-mknode
}

set -x

main
