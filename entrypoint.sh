#!/bin/sh

echo "${CRON} /usr/local/bin/shepherd" > /etc/crontabs/root

/usr/sbin/crond -f -l 6 -L /dev/stdout -d 6