# Govee Temperature&Humidity Telegraf Logging

Temperature and humidity logging into Telegraf for Govee sensors.


## Environment variables

The following environment variables are needed for telegraf communication to
work:
|                     |                                               |
|---------------------|-----------------------------------------------|
| `TELEGRAF_HOST`     | IP of remote telegraf server                  |
| `TELEGRAF_PORT`     | Port to use for telegraf server communication |
| `TELEGRAF_BUCKET`   | Telegraf bucket                               |
| `TELEGRAF_USERNAME` | Telegraf user name                            |
| `TELEGRAF_PASSWORD` | Telegraf password                             |

The following environment variables are for troubleshooting purposes and
usually require no configuration:

|                     |                                               |
|---------------------|-----------------------------------------------|
| `PASSIVE`           | If set to `1`, use passive LE scanning        |
| `DEBUG`             | If set to `1`, additional debugging is shown  |


## Run Docker Image

To run the docker image, you can use the following command (change values in
brackets):
~~~bash
docker run \
    -v /var/run/dbus/:/var/run/dbus/:z \
    --privileged \
    -e TELEGRAF_HOST=<ip> \
    -e TELEGRAF_PORT=<port> \
    -e TELEGRAF_BUCKET=<bucket> \
    -e TELEGRAF_USERNAME=<user> \
    -e TELEGRAF_PASSWORD=<password> \
    medo64/govee2telegraf:latest
~~~


## Health Check

Health check is available for container verification. It will return zero exit
code if execution was successful and non-zero code if check has failed.

To verify that container is receiving bluetooth Govee data:
~~~bash
/app/health
~~~

To verify that data is successfully sent to Telegraf:
~~~bash
/app/health -s
~~~


## Create Docker Image

To create docker image, you need to be on Alpine Linux system and install the
following prerequisites:
~~~bash
apk add build-base cmake pkgconfig bluez-dev dbus-dev
~~~

After that you can create image using:
~~~bash
make all
~~~


## Dependencies

### GoveeBTTempLogger Application

Temperatures are read using GoveeBTTempLogger application that is present in
the `lib` directory.


#### Compile

Install prerequisites:
~~~sh
apk add build-base cmake pkgconfig bluez-dev dbus-dev
~~~

To compile use:
~~~bash
cd lib/GoveeBTTempLogger
cmake -B ./build
cmake --build ./build
~~~

Output is in the `build` directory.


#### Git

It was added to project using:
~~~sh
git subtree add --prefix lib/GoveeBTTempLogger https://github.com/wcbonner/GoveeBTTempLogger.git master --squash
~~~

To update its content use:
~~~sh
git subtree pull --prefix lib/GoveeBTTempLogger https://github.com/wcbonner/GoveeBTTempLogger.git master --squash
~~~
