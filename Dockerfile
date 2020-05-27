FROM docker

ENV CRON='*/5 * * * *'
ENV FILTER_SERVICES=''

RUN apk add --update --no-cache bash curl

COPY shepherd /usr/local/bin/shepherd
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD ["sh", "-c", "/entrypoint.sh && /usr/sbin/crond -l 2 -f"]
