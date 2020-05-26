#!/bin/sh

echo "${CRON} /usr/local/bin/shepherd" > /etc/crontabs/root

/usr/sbin/crond -l 2 -f