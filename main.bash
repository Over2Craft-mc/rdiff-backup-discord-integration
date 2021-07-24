#!/bin/bash

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if test -f ${WORK_DIR}/lock.pid
then
  lockpid=`cat ${WORK_DIR}/lock.pid`
  lockpid_msg="Looks like a backup process has already started with PID ${lockpid}"
  DISCORD_WEBHOOK=${DISCORD_WEBHOOK_BACKUP}
  export DISCORD_WEBHOOK
  ${WORK_DIR}/discord.sh \
    --username "Backup" \
    --title "BACKUP ${DATE}" \
    --description "${lockpid_msg}" \
    --text "${MENTION}" \
    --color ${COLOR_ALERT} \
  exit
fi

echo "PID=$BASHPID" > ${WORK_DIR}/lock.pid

echo "Start backuping..."
bash ${WORK_DIR}/backup.bash
echo "Backup done, result sent to webhook"
echo "Starting storage check..."
bash ${WORK_DIR}/storage-check.bash
echo "Storage-check done, result sent to webhook"

rm ${WORK_DIR}/lock.pid
