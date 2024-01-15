#! /usr/bin/env nix-shell
#! nix-shell -i bash --packages procps gnugrep

loggedInUsers=$(w -h | grep -vc sddm)
#loggedInUsers=$(w -h | wc -l)

if [ ${loggedInUsers} -eq 0 ]
then
    shutdown
else
    echo $loggedInUsers
    wall Backup fertig der PC darf heruntergefahren werden. --nobanner
fi
