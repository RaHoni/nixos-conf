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

########################################
# Generate AGE keypair
########################################

key_output="$(age-keygen)"

private_key="$(printf '%s\n' "$key_output" | grep '^AGE-SECRET-KEY-')"
public_key="$(printf '%s\n' "$key_output" | grep 'public key:' | awk '{print $4}')"

if [[ -z "$private_key" || -z "$public_key" ]]; then
    echo "Failed to generate AGE key"
    exit 1
fi

echo "Generated public key:"
echo "  $public_key"
echo

########################################
# Find index of anchor == hostname
########################################

index="$(
  yq -r '
    .keys
    | to_entries[]
    | select(.value | anchor == $hostname)
    | .key
  ' "$FILE"
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

nixos-anywhere --disk-encryption-keys /var/lib/sops-nix/key.txt <(echo $key_output) --flake ".#${hostname}" "$target"
