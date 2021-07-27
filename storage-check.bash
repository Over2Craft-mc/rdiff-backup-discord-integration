DATE=$(date +%d-%m-%Y_%H\h%M)

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

LOG_DIR=${WORK_DIR}/log
mkdir -p ${LOG_DIR}

source "${WORK_DIR}/settings.bash"

IP_ADDR=`hostname -I | awk '{print $1}'`


log_send=${LOG_DIR}/filesystems_${DATE}.log

couleur=${COLOR_OK}

space_used_notify=80

fileSystems=($(df -h | sed 1d | grep -v 'tmpfs' | awk '{print $1}' | xargs -n1 | sort -u | xargs))

for fs in "${fileSystems[@]}"
do

    spaceUsed=`df -h | grep -m 1 ${fs} | awk '{printf $3}'`
    spaceAvailable=`df -h | grep -m 1 ${fs} | awk '{printf $4}'`
    spaceTotal=`df -h | grep -m 1 ${fs} | awk '{printf $2}'`
    spaceUsedPourcent=`df -h | grep -m 1 ${fs} | awk '{printf $5}'`
    spaceUsedPourcentWithout=`df -h | grep -m 1 ${fs} | awk '{printf $5}' | sed 's/.$//'`
    mountedPointOfi=`df -h | grep -m 1 ${fs} | awk '{printf $6}'`

    if [[ "${fs}" = "overlay" ]]
    then
        mountedPointOfi="`df -h | grep -m 1 ${fs} | awk '{printf $6}' | cut -f1,2,3,4,5 -d'/'`/[...]"
    fi

    echo -n " ${mountedPointOfi} :\n" >> ${log_send}
    echo -n "--> ${fs}\n" >> ${log_send}
    echo -n "Total space: ${spaceTotal}\n" >> ${log_send}
    echo -n "Available space : ${spaceAvailable}\n" >> ${log_send}
    echo -n "Space used : ${spaceUsed} (${spaceUsedPourcent})\n\n" >> ${log_send}
    echo "${fs}"
    if (( "${spaceUsedPourcentWithout}" >= ${space_used_notify} ))
    then
        couleur=${COLOR_ALERT}
            notify_owner=${MENTION}
    fi

done

DISCORD_WEBHOOK=${DISCORD_WEBHOOK_STORAGE_CHECK}
export DISCORD_WEBHOOK

sed -i ':a;N;$!ba;s/\n/\\n/g' ${log_send}

text_discord=`cat ${log_send}`

${WORK_DIR}/discord.sh \
    --username "Disk space" \
    --title "[${IP_ADDR}] Disk space ${DATE}" \
    --description "${text_discord}" \
    --text "${notify_owner}" \
    --color ${couleur}
