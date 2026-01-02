# Install

## Server

Limit the size of /tmp and /var/cache via

```bash
btrfs qgroup limit 30G /btrfs/tmp
btrfs qgroup limit 30G /btrfs/cache
```

## framework

### Full disk encryption

To add additional slots use

```bash
systemd-cryptenroll --tpm2-with-pin true --tpm2-device /dev/tpmrm0 /dev/nvme0n1p2
systemd-cryptenroll --fido2-with-user-presence true \\
--fido2-device=auto --fido2-with-client-pin true
systemd-cryptenroll --recovery-key
```
