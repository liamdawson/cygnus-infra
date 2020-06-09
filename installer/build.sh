#!/usr/bin/env bash

set -xeuo pipefail

mkdir -p "/workdir/iso" && cd "/workdir/iso"

if ! [[ -f /output/netinst.iso ]]; then
    curl -fsSL "https://mirror.aarnet.edu.au/pub/debian-cd/10.4.0/amd64/iso-cd/debian-10.4.0-amd64-netinst.iso" -o /output/netinst.iso
fi

bsdtar -C /workdir/iso -xf /output/netinst.iso

cd /workdir/iso/install.amd/
cp /preseed.cfg .
gunzip initrd.gz
echo "preseed.cfg" | cpio -H newc -o -A -F initrd
gzip initrd

cd /workdir/iso
set +e
find . -follow -type f ! -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt
set -e
dd if=/output/netinst.iso bs=1 count=432 of=/workdir/netinst-mbr.raw

xorriso -as mkisofs \
  -r -V 'cygnus-hypervisor' \
  -o /output/cygnus-hypervisor.iso \
  -J -J -joliet-long \
  -cache-inodes \
  -isohybrid-mbr /workdir/netinst-mbr.raw \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -boot-load-size 4 -boot-info-table -no-emul-boot \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
  -no-emul-boot \
  -isohybrid-gpt-basdat \
  -isohybrid-apm-hfsplus \
  .

exit 0

(
    lb config \
        -b iso \
        --cache false \
        --apt-recommends true \
        --architectures amd64 \
        --binary-images iso-hybrid \
        --debian-installer cdrom \
        --debian-installer-gui false \
        --mode debian \
        --archive-areas "main contrib non-free" \
        --security true \
        --win32-loader false \
        --updates true \
        --debconf-frontend noninteractive \
        --debconf-priority critical \
        --debian-installer-preseed /preseed.cfg \
        --distribution buster \
        --image-name cygnus-hypervisor \
        --linux-flavours amd64 \
        --uefi-secure-boot enable \
        --parent-mirror-bootstrap http://ftp.au.debian.org/debian/ \
        --parent-mirror-binary http://ftp.au.debian.org/debian/ \
        --mirror-bootstrap http://ftp.au.debian.org/debian/ \
        --mirror-binary http://ftp.au.debian.org/debian/

    cat <<EOFL >> config/package-lists/live.list.chroot
cockpit
libvirt-clients
libvirt-daemon-system
nfs-kernel-server
openssh-server
qemu-kvm
ssh-import-id
sudo
unattended-upgrades
vim
EOFL

    lb build; ls /workdir
)

cp /workdir/cygnus* /output/
cd /workdir
tar -cf /output/config.tar config
