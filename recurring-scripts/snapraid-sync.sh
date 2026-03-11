# Sets up snapraid cronjob maintenence scripts

(crontab -l 2>/dev/null; echo "0 3 * * * /usr/bin/snapraid sync") | crontab -