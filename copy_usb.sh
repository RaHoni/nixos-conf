devicepath=$(systemd-escape -up -- "$1")
start=$(date +%s)
whoami
[[ "$devicepath" =~ ^/dev/sd[a-z]1$ ]] || exit 0
#Close standard output file descriptor
#    echo "This line will appear in $LOG_FILE, not 'on screen'"
echo "Starting with $devicepath"
fatlabel "$devicepath" "Freizeit 25"
mkdir -p "/mnt/$devicepath"
mount "$devicepath" "/mnt/$devicepath"
#rm -r /mnt$devicepath/* || true
rsync -rLP /usbcopy/* "/mnt/$devicepath"
umount "$devicepath"
end=$(date +%s)

runtime=$((end-start))
echo Runtime $runtime
#eject "$devicepath"
