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

# Environment
ENV ENV=/etc/profile
RUN echo "alias ll='ls -la'" > /etc/profile.d/alias.sh

# Executables
WORKDIR /app
COPY lib/GoveeBTTempLogger/build/goveebttemplogger .
COPY src/telegraf-push-govee.sh .
COPY src/health.sh health
RUN chmod +x goveebttemplogger
RUN chmod +x telegraf-push-govee.sh
RUN chmod +x health

# Done
ENTRYPOINT ["/bin/ash", "-c", "/app/telegraf-push-govee.sh" ]
