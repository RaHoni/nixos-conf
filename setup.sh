#! /usr/bin/env nix-shell
#! nix-shell -i bash --packages git sops yq-go nebula cryptsetup

hostname=""
luksDevice="/dev/disk/by-uuid/d52694cc-e7b0-4b7e-b638-8251d8609b9e"
luksNebulaPath="nebula"
nebulaDomain="nb.honermann.info"

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

updateNebula() {
    
    sudo cryptsetup open $luksDevice luksUSBDeviceNebula
    sudo mount /dev/mapper/luksUSBDeviceNebula /mnt

    for path in secrets/*; do
        echo $path
        hostname="${path##*/}"
        if [ -f "/mnt/${luksNebulaPath}/${hostname}.${nebulaDomain}.crt" ]; then
            crt=$(<"/mnt/${luksNebulaPath}/${hostname}.${nebulaDomain}.crt")
            key=$(<"/mnt/${luksNebulaPath}/${hostname}.${nebulaDomain}.key")
            echo $crt
            echo \{\"nebula\": {\"${hostname}.key\": \"$key\",\"${hostname}.crt\": \"$crt\"\}} | yq -p json > secrets/$hostname/nebula.yaml
            sops -i -e secrets/$hostname/nebula.yaml
        fi
    done

    #umount and lock usb stick (try again if still busy)
    until sudo umount /mnt; do
        sleep 1
    done
    until sudo cryptsetup close /dev/mapper/luksUSBDeviceNebula; do
        sleep 1
    done

    git add secrets
    git commit -m "nebula: Updated all nebula certs"

}

cd $(dirname "$0")
pwd
case $1 in
    sshKeys)
    hostname=$2
    sshKeys
    exit 0
    ;;
updateNebula)
    updateNebula
    exit 0
    ;;
    *)
    exit 1
    ;;
esac
