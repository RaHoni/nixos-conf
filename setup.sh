#! /usr/bin/env nix-shell
#! nix-shell -i bash --packages git sops yq-go

hostname=""

sshKeys() {
    mkdir -p secrets/$hostname
    ssh-keygen -t ed25519 -N "" -f /tmp/ed25519
    ssh-keygen -t rsa -N "" -f /tmp/rsa
    ed25519key=$(</tmp/ed25519)
    rsakey=$(</tmp/rsa)
    echo \{\"ssh_host_ed25519_key\": \"$ed25519key\",\"ssh_host_rsa_key\": \"$rsakey\"\} | yq -p json > secrets/$hostname/sshd.yaml
    sops -i -e secrets/$hostname/sshd.yaml
    git add secrets/$hostname/sshd.yaml
    git commit -o secrets/ssl-proxy/sshd.yaml -m "$hostname: Added ssh hostkeys for $hostname"
    }
    

cd $(dirname "$0")
pwd
case $1 in
    sshKeys)
    hostname=$2
    sshKeys
    exit 0
    ;;
    *)
    exit 1
    ;;
esac
