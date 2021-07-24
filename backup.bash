#!/bin/bash

## Définition des variables principales

DATE=$(date +%d-%m-%Y_%H\h%M)
WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
LOG_DIR="${WORK_DIR}/log"
mkdir -p "${LOG_DIR}"

source "${WORK_DIR}/settings.bash"

BACKUP_DIR="/var/lib/pterodactyl/storage"

if [ -z ${BACKUP_DIR+x} ]; then echo "BACKUP_DIR is missing in BACKUP_DIR"; exit; fi

## Création du répertoire temporaire d'export des dumps MySQL
mkdir -p /tmp/backup/mysql

## Export des bases
export_db=${LOG_DIR}/export_db_${DATE}.log
export_db_tmp=${LOG_DIR}/export_db_tmp.log

for DB in $(mysql -e 'show databases' -s --skip-column-names); do
    echo "Dumping ${DB}"
    mysqldump -v $DB > "/tmp/backup/mysql/$DB.sql" 2>> ${export_db_tmp}
done

grep --ignore-case "error" ${export_db_tmp} >> ${export_db}

rm -f ${export_db_tmp}

## Creation du fichier de log envoye a Discord
log_send=${LOG_DIR}/backup_${DATE}.log

## Variable couleur OK par defaut
couleur=0x67C627

for dir_name in "${!dir_to_save[@]}";
do
    dir_source=${dir_to_save[${dir_name}]};

    ## Exécution du backup
    log_temp=${LOG_DIR}/backup_${dir_name}_${DATE}.log
    echo "Incremental saving of ${dir_source} to ${BACKUP_DIR}/${dir_name}"
    rdiff-backup -v5 ${dir_source} ${BACKUP_DIR}/${dir_name} > ${log_temp} 2>&1

    ## Gestion des erreurs
    if [ "$?" = 0 ]
    then
        echo -ne "Backup du répertoire ${dir_source} \nOK\n\n" >> ${log_send}
    else
        echo -ne "Backup du répertoire ${dir_source} \nFAILED\nCause :\n" >> ${log_send}
        cat ${log_temp} >> ${log_send}
        echo -ne "\n" >> ${log_send}
        couleur=0xD21D38
        notify_owner=${MENTION}
    fi

    rm -f ${log_temp}
done

## Suppression répertoire temporaire d'export des dumps MySQL
rm -rf /tmp/backup/mysql

## Declaration de la variable DISCORD_WEBHOOK
DISCORD_WEBHOOK=${DISCORD_WEBHOOK_BACKUP}
export DISCORD_WEBHOOK

## Envoi
text_discord=`cat $log_send | jq -Rs . | cut -c 2- | rev | cut -c 2- | rev`

${WORK_DIR}/discord.sh \
    --username "RoboBackup" \
    --title "RECAPITULATIF BACKUP ${DATE}" \
    --description "${text_discord}" \
    --text "${notify_owner}" \
    --color ${couleur}

${WORK_DIR}/discord.sh \
    --username "RoboBackup" \
    --file ${export_db}
