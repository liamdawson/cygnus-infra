# Cygnus Infrastructure

Infrastructure (e.g. hypervisor host) configuration for my homelab Kubernetes
cluster.

## Resources

- [Architectural Decision Records](./doc/adr/)
- [Known Issues](./doc/ISSUES.md)
- [Record of commands](./doc/RECORD.md)

## pi-hole notes

```shell
echo "address=/ldaws.net/192.168.4.200" > /etc/dnsmasq.d/00-ldaws-net-cygnus-default.conf
pihole-FTL dnsmasq-test
pihole restartdns
```
