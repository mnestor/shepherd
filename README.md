# Shepherd

[![Docker Stars](https://img.shields.io/docker/stars/mnestor/shepherd.svg)](https://hub.docker.com/r/mnestor/shepherd/) [![Docker Pulls](https://img.shields.io/docker/pulls/mnestor/shepherd.svg)](https://hub.docker.com/r/mnestor/shepherd/)

Clone of [djmaze/shepherd](https://github.com/djmaze/shepherd) to use cron instead of sleep so you can set more complicated run times. Like every 5 minutes only in the early hours of the day (CRON="*/5 0-5 * * *")

A Docker swarm service for automatically updating your services whenever their base image is refreshed.

## Usage

    docker service create --name shepherd \
                          --constraint "node.role==manager" \
                          --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock,ro \
                          mnestor/shepherd

## Or with docker-compose
    version: "3"
    services:
      ...
      shepherd:
        build: .
        image: mnestor/shepherd
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
        deploy:
          placement:
            constraints:
            - node.role == manager

### Configuration

Shepherd will try to update your services every 5 minutes by default. You can adjust this value using the `CRON` variable.

You can prevent services from being updated by appending them to the `BLACKLIST_SERVICES` variable. This should be a space-separated list of service names.

Alternatively you can specify a filter for the services you want updated using the `FILTER_SERVICES` variable. This can be anything accepted by the filtering flag in `docker service ls`.

You can enable private registry authentication by setting the `WITH_REGISTRY_AUTH` variable.

You can enable connection to insecure private registry by setting the `WITH_INSECURE_REGISTRY` variable.

You can force image deployment whatever the architecture by setting the `WITH_NO_RESOLVE_IMAGE` variable.

You can enable notifications on service update with apprise, using the [apprise microservice](https://github.com/djmaze/apprise-microservice) and the `APPRISE_SIDECAR_URL` variable. See the file [docker-compose.apprise.yml](docker-compose.apprise.yml) for an example.

Example:

    docker service create --name shepherd \
                        --constraint "node.role==manager" \
                        --env CRON="*/5 * * * *" \
                        --env BLACKLIST_SERVICES="shepherd my-other-service" \
                        --env WITH_REGISTRY_AUTH="true" \
                        --env WITH_INSECURE_REGISTRY="true" \
                        --env WITH_NO_RESOLVE_IMAGE="true" \
                        --env FILTER_SERVICES="label=com.mydomain.autodeploy" \
                        --env APPRISE_SIDECAR_URL="apprise-microservice:5000" \
                        --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock,ro \
                        --mount type=bind,source=/root/.docker/config.json,target=/root/.docker/config.json,ro \
                        mnestor/shepherd

## How does it work?

Shepherd just triggers updates by updating the image specification for each service, removing the current digest.

Most of the work is thankfully done by Docker which [resolves the image tag, checks the registry for a newer version and updates running container tasks as needed](https://docs.docker.com/engine/swarm/services/#update-a-services-image-after-creation).

Also, Docker handles all the work of [applying rolling updates](https://docs.docker.com/engine/swarm/swarm-tutorial/rolling-update/). So at least with replicated services, there should be no noticeable downtime.
