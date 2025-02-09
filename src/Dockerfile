FROM alpine:latest

USER root

# Basic
RUN apk add bash
RUN apk add openrc
RUN mkdir -p /run/openrc/exclusive
RUN touch /run/openrc/softlevel

# DBus
RUN apk add dbus
RUN rc-update add dbus

# Bluetooth
RUN apk add bluez
RUN rc-update add bluetooth default

# GoveeBTTempLogger
RUN apk add bluez-dev libstdc++

# Executables
WORKDIR /app
COPY lib/GoveeBTTempLogger/build/goveebttemplogger /app
COPY src/telegraf-push-govee.sh /app
RUN chmod +x /app/goveebttemplogger
RUN chmod +x /app/telegraf-push-govee.sh

# Done
ENTRYPOINT ["/bin/ash", "-c", "/app/telegraf-push-govee.sh" ]
