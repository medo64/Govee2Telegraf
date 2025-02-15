FROM alpine:latest

USER root

# Environment
ENV ENV="/etc/profile"
RUN echo "alias ll='ls -la'" > /etc/profile.d/00-aliases.sh

# Services
RUN apk add openrc
RUN mkdir -p /run/openrc/exclusive
RUN touch /run/openrc/softlevel

# DBus
RUN apk add dbus
RUN rc-update add dbus

# Bluetooth
RUN apk add bluez
RUN rc-update add bluetooth default

# Prerequisites (GoveeBTTempLogger)
RUN apk add bluez-dev libstdc++

# Executables (GoveeBTTempLogger)
WORKDIR /app/lib
COPY lib/GoveeBTTempLogger/build/goveebttemplogger .
RUN chmod +x goveebttemplogger

# Executables
WORKDIR /app
COPY src/init.sh init
COPY src/health.sh health
RUN chmod +x init
RUN chmod +x health

# Done
HEALTHCHECK --start-period=120s --start-interval=3s --interval=15s --retries=10 --timeout=1s \
    CMD /app/health
ENTRYPOINT ["/bin/ash", "-c", "/app/init" ]
