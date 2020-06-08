.PHONY: iso
iso: cache/remastered-debian-cd.iso

cache/debian-10.4.0-amd64-xfce-CD-1.iso: 
	./scripts/pull-iso

cache/remastered-debian-cd.iso: initrd/* cache/debian-10.4.0-amd64-xfce-CD-1.iso
	./scripts/remaster-iso
