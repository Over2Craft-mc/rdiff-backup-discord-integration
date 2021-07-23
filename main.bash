#!/bin/bash

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

test -f ${WORK_DIR}/lock.pid && echo "Looks like a backup process has already started with PID" && cat ${WORK_DIR}/lock.pid && exit

echo "PID=$BASHPID" > ${WORK_DIR}/lock.pid

echo "Start backuping..."
bash ${WORK_DIR}/backup.bash
echo "Backup done, result sent to webhook"
echo "Starting storage check..."
bash ${WORK_DIR}/storage-check.bash
echo "Storage-check done, result sent to webhook"

rm ${WORK_DIR}/lock.pid
