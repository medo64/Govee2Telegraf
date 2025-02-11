#!/bin/ash

ANSI_RED="\e[91m"
ANSI_YELLOW="\e[93m"
ANSI_MAGENTA="\e[95m"
ANSI_CYAN="\e[96m"
ANSI_RESET="\e[0m"

echo -e "${ANSI_MAGENTA}Entrypoint reached${ANSI_RESET}"
echo

MISSING_TELEGRAF_VARIABLES=
if [ "$TELEGRAF_HOST" = "" ]; then MISSING_TELEGRAF_VARIABLES="$MISSING_TELEGRAF_VARIABLES TELEGRAF_HOST"; fi
if [ "$TELEGRAF_PORT" = "" ]; then MISSING_TELEGRAF_VARIABLES="$MISSING_TELEGRAF_VARIABLES TELEGRAF_PORT"; fi
if [ "$TELEGRAF_BUCKET" = "" ]; then MISSING_TELEGRAF_VARIABLES="$MISSING_TELEGRAF_VARIABLES TELEGRAF_BUCKET"; fi
if [ "$TELEGRAF_USERNAME" = "" ]; then MISSING_TELEGRAF_VARIABLES="$MISSING_TELEGRAF_VARIABLES TELEGRAF_USERNAME"; fi
if [ "$TELEGRAF_PASSWORD" = "" ]; then MISSING_TELEGRAF_VARIABLES="$MISSING_TELEGRAF_VARIABLES TELEGRAF_PASSWORD"; fi
MISSING_TELEGRAF_VARIABLES=`echo $MISSING_TELEGRAF_VARIABLES | xargs`

if [ "$MISSING_TELEGRAF_VARIABLES" != "" ]; then
    echo -e "${ANSI_RED}Missing environment variables:"
    echo $MISSING_TELEGRAF_VARIABLES | xargs -n 1 | sed 's/^/  - /'
    echo -e "${ANSI_RESET}"
fi

EXTRA_ARGS=
if [ "$PASSIVE" == "1" ] || [ "$PASSIVE" == "true" ] || [ "$PASSIVE" == "yes" ]; then
    EXTRA_ARGS="--passive"
    echo -e "${ANSI_YELLOW}Using passive mode${ANSI_RESET}"
    echo
fi


while(true); do

    TIME_START=$(date +%s)
    while IFS= read -r LINE; do
        INPUT=`echo "$LINE" | grep -E '\(Temp\).*\(Humidity\).*\(Battery\)'`
        if [ "$INPUT" == "" ]; then continue; fi

        DATA=`echo $INPUT | awk '{print $4 " " $6 " " $8}' | tr -dc '0-9-. '`
        DEVICE=`echo $INPUT | awk '{print $2}' | tr -d '[]' | tr '[:lower:]' '[:upper:]'`

        TEMPERATURE=`echo $DATA | cut -d ' ' -f 1`
        HUMIDITY=`echo $DATA | cut -d ' ' -f 2`
        BATTERY=`echo $DATA | cut -d ' ' -f 3`

        echo -ne "${ANSI_CYAN}"
        printf "%s %5s°C %4s%% (%s%%)\n" $DEVICE $TEMPERATURE $HUMIDITY $BATTERY
        echo -ne "${ANSI_RESET}"

        if [ "$MISSING_TELEGRAF_VARIABLES" == "" ]; then
            CONTENT="temp,device=$DEVICE temp=${TEMPERATURE},humidity=${HUMIDITY},battery=${BATTERY} `date +%s`"$'\n'
            CONTENT_LEN=$(echo -en ${CONTENT} | wc -c)
            echo -ne "POST /api/v2/write?u=$TELEGRAF_USERNAME&p=$TELEGRAF_PASSWORD&bucket=${TELEGRAF_BUCKET}&precision=s HTTP/1.0\r\nHost: $TELEGRAF_HOST\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: ${CONTENT_LEN}\r\n\r\n${CONTENT}" | nc -w 15 $TELEGRAF_HOST $TELEGRAF_PORT
        else
            echo -e "${ANSI_RED}Not sending to Telegraf ($MISSING_TELEGRAF_VARIABLES)${ANSI_RESET}"
            echo
        fi
    done < <(/app/goveebttemplogger $EXTRA_ARGS)
    TIME_END=$(date +%s)

    echo
    echo -e "${ANSI_RED}Application crashed${ANSI_RESET}"

    TIME_DIFF=$((TIME_END - TIME_START))
    if [ $TIME_DIFF -eq 0 ]; then  # don't restart if it crashes too fast
        exit 1
    fi

    echo -ne "${ANSI_YELLOW}Restarting${ANSI_RESET}"

    for i in 1 2 3 4 5; do
        echo -ne "${ANSI_YELLOW}.${ANSI_RESET}"
        sleep 1.1
    done
    echo

    echo

done
