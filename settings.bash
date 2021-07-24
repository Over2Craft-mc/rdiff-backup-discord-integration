#!/bin/bash

BACKUP_DIR="/mnt/backup"

DISCORD_WEBHOOK_BACKUP=""

DISCORD_WEBHOOK_STORAGE_CHECK=""

# Id to mention if backup fail or storage overlaps 80% of a mounted device
MENTION="<@65476532436536534>"

COLOR_OK="0x67C627"
COLOR_ALERT="0xD21D38"

declare -A dir_to_save
dir_to_save["mysql"]="/tmp/backup/mysql"
dir_to_save["volumes"]="/var/lib/docker/volumes"
dir_to_save["www"]="/var/www"