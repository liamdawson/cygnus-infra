#!/usr/bin/env bash

set -xeuo pipefail

mkdir -p "/workdir/iso" && cd "/workdir/iso"

if ! [[ -f /output/netinst.iso ]]; then
    curl -fsSL "https://mirror.aarnet.edu.au/pub/debian-cd/10.4.0/amd64/iso-cd/debian-10.4.0-amd64-netinst.iso" -o /output/netinst.iso
fi

bsdtar -C /workdir/iso -xf /output/netinst.iso

cd /workdir/iso/install.amd/
cp /preseed.cfg .
cp /late-command.sh .
gunzip initrd.gz
echo "preseed.cfg" | cpio -H newc -o -A -F initrd
echo "late-command.sh" | cpio -H newc -o -A -F initrd
gzip initrd

cd /workdir/iso
set +e
find . -follow -type f ! -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt
set -e
dd if=/output/netinst.iso bs=1 count=432 of=/workdir/netinst-mbr.raw

xorriso -as mkisofs \
  -r -V 'cygnus-aio' \
  -o /output/cygnus-aio.iso \
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
