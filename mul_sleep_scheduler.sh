#!/bin/bash

create_start_job () {
    echo "========>Create start scheduler"

    start_job=$(gcloud beta scheduler jobs describe "startup-instance-$3-$1" --quiet|grep name|awk '{split($0,a,"/");print a[6]}')
    if [ "startup-instance-$3-$1" == "$start_job" ]
    then
        echo "Remove the existing job"
        gcloud beta scheduler jobs delete "startup-instance-$3-$1"
    fi
    gcloud beta scheduler jobs create pubsub "startup-instance-$3-$1" \
            --schedule "$start_cron" \
            --topic "start-instance-event-$3" \
            --message-body "${2}" \
            --time-zone 'Asia/Singapore'
}

create_stop_job () {
    echo "========>Create stop scheduler"

    stop_job=$(gcloud beta scheduler jobs describe "shutdown-instance-$3-$1" --quiet|grep name|awk '{split($0,a,"/");print a[6]}')
    if [ "shutdown-instance-$1" == "$stop_job" ]
    then
        echo "Remove the existing job"
        gcloud beta scheduler jobs delete "shutdown-instance-$3-$1"
    fi
    gcloud beta scheduler jobs create pubsub "shutdown-instance-$3-$1"\
            --schedule "$stop_cron" \
            --topic "stop-instance-event-$3" \
            --message-body "${2}" \
            --time-zone 'Asia/Singapore'
}

env=$1
# Indicate the ENV setting for GCP project
gcloud config configurations activate "$env-settings"
start_cron="0 9 * * 1-5"
stop_cron="0 19 * * 1-5"
zone=$2

workday_vms=$3

items=$(printf %s\\n ${workday_vms}|printf %s "$(cat)"|jq -R -s 'split("\n")')

messsage_body='{"zone":"'"$zone"'", "instances": '${items}'}'

create_start_job "workday" "$messsage_body" $env

create_stop_job "workday" "$messsage_body" $env
