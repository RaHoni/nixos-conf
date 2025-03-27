# Install

## Server

Limit the size of /tmp and /var/cache via 

```
btrfs qgroup limit 30G /btrfs/tmp
btrfs qgroup limit 30G /btrfs/cache
```