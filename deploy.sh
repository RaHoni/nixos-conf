#!/usr/bin/env nix-shell
#!nix-shell -i bash -p yq-go age nixos-anywhere
set -euo pipefail

FILE=".sops.yaml"

if (( $# != 2 )); then
    >&2 echo "Wrong number of arguments\nUse $0 <hostname> <ssh-target>"
    exit 1
fi

hostname=$1
target=$2
echo "Rotating SOPS key for anchor: $hostname"
echo

# Create a temporary directory
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
    rm -rf "$temp"
}
trap cleanup EXIT

# Create the directory where sops expects to find the agekey

install -d -m755 "$temp/var/lib/sops-nix"

########################################
# Generate AGE keypair
########################################

keypath="$temp/var/lib/sops-nix/key.txt"

age-keygen -o $keypath
key_output=<$keypath

public_key="$(age-keygen -y $keypath)"


if [[ -z "$public_key" ]]; then
    echo "Failed to generate AGE key"
    exit 1
fi

echo "Generated public key:"
echo "  $public_key"

########################################
# Find index of anchor == hostname
########################################

index="$(
  yq -r "
.keys
| .[]
| select(anchor == \"$hostname\")
| key
" "$FILE"
)"
if [[ -z "$index" || "$index" == "null" ]]; then
    echo "No anchor named '$hostname' found in .keys[]"
    # Build menu: index | anchor | value
    mapfile -t entries < <(
        yq -r '.keys|.[]|"\(key)|\(anchor)|\(.)"' "$FILE"
    )

    options=()
    indices=()

    for entry in "${entries[@]}"; do
        IFS="|" read -r idx anchor value <<< "$entry"
        options+=("${anchor} → ${value:0:15}")
        indices+=("$idx")
    done

    echo "Select the key (anchor → value) to replace:"
    select opt in "${options[@]}" "Quit"; do
        case "$opt" in
            "Quit")
                exit 0
                ;;
            "")
                echo "Invalid selection"
                ;;
            *)
                index="${indices[$((REPLY-1))]}"
                break
                ;;
        esac
    done
fi

# Updating agekey in .sops.yaml
yq -i ".keys[$index] = \"$public_key\"" "$FILE"

# Updating sops-files
find secrets -name "*" -type f -exec sops updatekeys {} -y \;

nixos-anywhere --extra-files "$temp"  --flake ".#${hostname}" "$target" --generate-hardware-config nixos-generate-config "$hostname/hardware-configuration.nix"
