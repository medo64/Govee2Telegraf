#!/bin/sh

ANSI_RESET="\e[0m"
ANSI_RED="\e[91m"
ANSI_GREEN="\e[92m"

SECONDS_MAX=60
TIMESTAMP_CURR=$(date +%s)

if [ "$1" = "-s" ]; then
    TIMESTAMP_LAST=$(cat /var/run/.govee2telegraf.send.timestamp 2>/dev/null || echo 0)
else
    TIMESTAMP_LAST=$(cat /var/run/.govee2telegraf.recv.timestamp 2>/dev/null || echo 0)
fi

TIMESTAMP_DIFF=$(( TIMESTAMP_CURR - TIMESTAMP_LAST ))

if [ $TIMESTAMP_DIFF -le $SECONDS_MAX ]; then
    echo -e "${ANSI_GREEN}Healthy${ANSI_RESET}"
    exit 0
else
    echo -e "${ANSI_RED}Not healthy${ANSI_RESET}"
    exit 1
fi
