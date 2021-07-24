#!/bin/bash

DATE=$(date +%d-%m-%Y_%H\h%M)
WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
LOG_DIR="${WORK_DIR}/log"

export_db=${LOG_DIR}/export_db_${DATE}.log
export_db_tmp=${LOG_DIR}/export_db_tmp.log
log_send=${LOG_DIR}/backup_${DATE}.log

source "${WORK_DIR}/settings.bash"

mkdir -p "${LOG_DIR}"
mkdir -p /tmp/backup/mysql

for DB in $(mysql -e 'show databases' -s --skip-column-names); do
    echo "Dumping ${DB}"
    mysqldump -v $DB > "/tmp/backup/mysql/$DB.sql" 2>> ${export_db_tmp}
done

grep --ignore-case "error" ${export_db_tmp} >> ${export_db}

rm -f ${export_db_tmp}

color=${COLOR_OK}

for dir_name in "${!dir_to_save[@]}";
do
    dir_source=${dir_to_save[${dir_name}]};

    log_temp=${LOG_DIR}/backup_${dir_name}_${DATE}.log
    echo "Incremental saving of ${dir_source} to ${BACKUP_DIR}/${dir_name}"
    rdiff-backup -v5 ${dir_source} ${BACKUP_DIR}/${dir_name} > ${log_temp} 2>&1

    if [ "$?" = 0 ]
    then
        echo -ne "Backup du répertoire ${dir_source} \nOK\n\n" >> ${log_send}
    else
        echo -ne "Backup du répertoire ${dir_source} \nFAILED\nCause :\n" >> ${log_send}
        cat ${log_temp} >> ${log_send}
        echo -ne "\n" >> ${log_send}
        color=${COLOR_ALERT}
        notify_owner=${MENTION}
    fi

    rm -f ${log_temp}
done

rm -rf /tmp/backup/mysql

DISCORD_WEBHOOK=${DISCORD_WEBHOOK_BACKUP}
export DISCORD_WEBHOOK

## Envoi
text_discord=`cat $log_send | jq -Rs . | cut -c 2- | rev | cut -c 2- | rev`

${WORK_DIR}/discord.sh \
    --username "Backup" \
    --title "BACKUP ${DATE}" \
    --description "${text_discord}" \
    --text "${notify_owner}" \
    --color ${color}

${WORK_DIR}/discord.sh \
    --username "Backup" \
    --file ${export_db}
