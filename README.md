# Rdiff-backup with discord integration

Easly incremental backup of directories with recap sent to discord and recap about system storage

## Requirements
* rdiff-backup
* curl
* jq
* cut - Cut characters from string (part of coreutils, included by default on most systems)
* rev - Reversing of characters (part of util-linux, included by default on most systems)

## Installations example
```
apt install rdiff-backup curl jq
chmod +x main.bash discord.sh backup.bash settings.bash storage-check.bash
```

### Schedule backup
```
crontab -e
```

```
# Edit this file to introduce tasks to be run by cron.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
#
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
#
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
#
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
0 3 * * * /bin/bash /root/backups/main.bash
```

### Fill in settings
Fill settings in `settings.bash`

# Thanks
* Inspired from https://github.com/aptlt/incremential_backup_rdiff_discord_integration and https://github.com/aptlt/disk_supervision_discord_integration with a few fixes
* https://github.com/ChaoticWeg/discord.sh to use discord webhooks pretty easly
