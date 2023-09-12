devicepath=$(systemd-escape -up -- $1)
echo $devicepath
echo $PATH
[[ $devicepath =~ ^/dev/sd[a-z]1$ ]] || exit 0
    #Close standard output file descriptor
#    echo "This line will appear in $LOG_FILE, not 'on screen'"
echo Starting with $devicepath
fatlabel $devicepath "Freizeit 23"
mkdir -p /mnt/$devicepath
mount $devicepath /mnt/$devicepath
rm -r /mnt/$devicepath/* || true
cp -r /usbcopy/* /mnt/$devicepath
umount $devicepath
#eject $devicepath
