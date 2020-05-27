FROM docker

ENV CRON='*/5 * * * *' \
    FILTER_SERVICES=''

COPY shepherd entrypoint.sh /usr/local/bin/
RUN apk add --update --no-cache bash curl && chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
