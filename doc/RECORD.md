# Command Record

## Getting started

(As of eb7e748)

```shell
$ sudo systemctl disable libvirt-guests
$ virsh pool-autostart default
Pool default marked as autostarted
$ virsh net-autostart kubenet
Network kubenet marked as autostarted
$ /usr/local/cygnus/mk-kube-server polaris 52:54:00:e3:df:83
+ sudo virt-install --name polaris --ram 2048 --vcpus 2 --disk size=64 --os-type linux --os-variant ubuntu18.04 --graphics none --network network=kubenet,mac=52:54:00:e3:df:83 --install kernel=/usr/local/cygnus/k3os/k3os-vmlinuz-amd64,initrd=/usr/local/cygnus/k3os/k3os-initrd-amd64 --extra-args 'console=ttyS0 boot_cmd="echo GA_PATH=/dev/vport0p1>/etc/conf.d/qemu-guest-agent" hostname=polaris ssh_authorized_keys=github:liamdawson k3os.mode=install k3os.install.silent=true k3os.install.device=/dev/vda k3os.hostname=polaris k3os.server_url=https://control.cygnus.home.ldaws.com:6443 k3os.k3s_args=server  ' --console=pty,target_type=serial --disk path=/var/lib/libvirt/images/k3os-amd64.iso,device=cdrom --noreboot

Starting install...
...
Installation finished. No error reported.
 * Rebooting system in 5 seconds (CTRL+C to cancel)
[   19.619822] reboot: Restarting system

Domain creation completed.
You can restart your domain by running:
  virsh --connect qemu:///system start polaris
$ sudo systemctl enable --now libvirt-domain@polaris && sleep 20
$ ssh rancher@192.168.53.7 sudo cat /var/lib/rancher/k3s/server/node-token
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx::server:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
$ /usr/local/cygnus/mk-kube-agent sirius 52:54:00:42:bc:2f "$(ssh rancher@192.168.53.7 sudo cat /var/lib/rancher/k3s/server/node-token)"
$ sudo systemctl enable --now libvirt-domain@sirius && sleep 20
$ ssh rancher@192.168.53.7 kubectl get nodes
NAME      STATUS   ROLES    AGE    VERSION
polaris   Ready    master   3m9s   v1.17.6+k3s1
sirius    Ready    <none>   25s    v1.17.6+k3s1
$ ssh rancher@192.168.53.7 cat /etc/rancher/k3s/k3s.yaml | sed -e 's#127.0.0.1:6443#control.cygnus.home.ldaws.com:6443#g'
apiVersion: v1
<snip>
# using ^ config, `kubectl get nodes` worked from my client machine
$ sudo systemctl set-default hypervisor
```
