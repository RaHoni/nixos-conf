devicepath=$(systemd-escape -up -- "$1")
start=$(date +%s)
whoami
[[ "$devicepath" =~ ^/dev/sd[a-z]1$ ]] || exit 0
    #Close standard output file descriptor
#    echo "This line will appear in $LOG_FILE, not 'on screen'"
echo "Starting with $devicepath"
mkdir -p "/mnt/$devicepath"
mount "$devicepath" "/mnt/$devicepath"
cd "/mnt/$devicepath"
pwd
sha256sum --status -c /home/raoul/Nextcloud/Ferienfreizeit/2024/chechsums.txt || eject "$devicepath"
cd /
umount "$devicepath"
end=$(date +%s)

runtime=$((end-start))
echo Runtime $runtime
#eject "$devicepath"
