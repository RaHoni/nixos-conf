#! /usr/bin/env nix-shell
#! nix-shell -i bash --packages git sops nebula cryptsetup

hostname=""
luksDevice="/dev/disk/by-uuid/d52694cc-e7b0-4b7e-b638-8251d8609b9e"
luksNebulaPath="nebula"
nebulaDomain="nb.honermann.info"

sshKeys() {
    mkdir -p secrets/$hostname
    
    ed25519key=/tmp/ed25519
    rsakey=/tmp/rsa

    ssh-keygen -t ed25519 -N "" -f $ed25519key
    ssh-keygen -t rsa -N "" -f $rsakey
    printf "ssh_host_ed25519_key: |\n$(awk '{print "    " $0}' ${ed25519key}) \nssh_host_rsa_key: |\n$(awk '{print "    " $0}' $rsakey)" > ./secrets/$hostname/sshd.yaml
    rm $ed25519key $rsakey
    sops -i -e secrets/$hostname/sshd.yaml
    git add secrets/$hostname/sshd.yaml
    git commit -o secrets/$hostname/sshd.yaml -m "$hostname: Added ssh hostkeys for $hostname"
    }

updateNebula() {
    
    openLuks

    for path in secrets/*; do
        echo $path
        hostname="${path##*/}"
        if [ -f "/mnt/${luksNebulaPath}/${hostname}.${nebulaDomain}.crt" ]; then
            printNebulaYAML $hostname
            sops -i -e secrets/$hostname/nebula.yaml
        fi
    done

    closeLuks

    git add secrets
    git commit -m "nebula: Updated all nebula certs"

}

addNebulaHost() {
    openLuks
    /mnt/${luksNebulaPath}/create.sh $hostname $nebulaIp $groups
    printNebulaYAML $hostname
    sops -i -e secrets/$hostname/nebula.yaml
    closeLuks

    git add ./secrets/$hostname/nebula.yaml
    git commit -m "nebula: Add Host $hostname"
}

printNebulaYAML() {
    #generate yaml file to store secrets
    printf "nebula:\n    $1.key: |\n        $(sed ':a;N;$!ba;s/\n/\n        /g' /mnt/${luksNebulaPath}/${1}.${nebulaDomain}.key)\n    $1.crt: |\n        $(sed ':a;N;$!ba;s/\n/\n        /g' /mnt/${luksNebulaPath}/${1}.${nebulaDomain}.crt)" > "secrets/$1/nebula.yaml"
}

openLuks() {
    sudo cryptsetup open $luksDevice luksUSBDeviceNebula
    sudo mount /dev/mapper/luksUSBDeviceNebula /mnt

}

closeLuks() {
    #umount and lock usb stick (try again if still busy)
    until sudo umount /mnt; do
        sleep 1
    done
    until sudo cryptsetup close /dev/mapper/luksUSBDeviceNebula; do
        sleep 1
    done

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
addNebula)
    hostname=$2 
    nebulaIp=$3
    groups=$4
    addNebulaHost 
    exit 0 
    ;;
    *)
    echo Unknown Command
    exit 1
    ;;
esac
