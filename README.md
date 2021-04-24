# Openrct2 multiarch docker

## Requirements

### Multiarch

[Docker buildx](https://github.com/docker/buildx/#with-buildx-or-docker-1903)

## build

`docker buildx --platform linux/amd64,linux/arm64 -t br0fessional/openrct:latest`

## Run via docker compose

- place your savegame on save/NAME_OF_YOUR_PARK

- set the park name in .env

- openrct will pickup the last autosave on restart

`docker-compose up --build`
