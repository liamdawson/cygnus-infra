#!/usr/bin/env bash

set -euo pipefail

cd "/tmp/workdir"

build-simple-cdd \
    --force-root \
    --profiles hypervisor \
    --dist buster \
    --profiles-udeb-dist buster \
    --debian-mirror http://ftp.au.debian.org/debian/ \
    --locale en_AU.UTF-8 \
    --keyboard us

# simple-cdd \
#     --dist buster \
#     --locale en_AU \
#     --keyboard ??? \
#     --profiles ??? \
#     --local-packages ??? \
#     --build-profiles ??? \
#     --auto-profiles ??? \
#     --debian-mirror http://ftp.au.debian.org/debian/ \
# 
# 
# 
# man simple-cdd

# germinate -S file:///seeds/ -s debian.buster \
    # -m http://ftp.au.debian.org/debian/ \
    # -a amd64 \
    # -c main,contrib,non-free \
    # -d buster,buster-updates

# debmirror \
#     --progress \
#     --dry-run \
#     --host=ftp.au.debian.org \
#     --method=rsync \
#     --dist=stable \
#     --arch=amd64 \
#     --nosource \
#     --diff=none \
#     --rsync-extra=doc,tools,trace \
#     /tmp/workdir/mirror

# man debmirror
