# [YT Download bot](https://github.com/ivan-leschinsky/download_bot/)

[![Docker Image](https://github.com/ivan-leschinsky/download_bot/actions/workflows/docker_image.yml/badge.svg)](https://github.com/ivan-leschinsky/download_bot/actions/workflows/docker_image.yml)
[![Docker latest version](https://img.shields.io/docker/v/vanopiano/download_bot.svg?sort=semver&color=success)](https://hub.docker.com/r/vanopiano/download_bot)
[![Docker Image size](https://img.shields.io/docker/image-size/vanopiano/download_bot.svg?sort=date)](https://hub.docker.com/r/vanopiano/download_bot/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/vanopiano/download_bot.svg)](https://hub.docker.com/r/vanopiano/download_bot)

### Telegram bot to download files with "youtube-dl"-like programs

About `PGID` and `PUID`: https://docs.linuxserver.io/general/understanding-puid-and-pgid

### Run in production:
.env example:
```
BOT_TOKEN=XXXXXXX
USER_TO_SEND=XXXXXXX
PUID=1000
PGID=1000
YDL_OPTIONS="--video-multistreams --merge-output-format mp4"
DOWNLOAD_DIR=./data
FILE_FORMAT="%(uploader)s/%(upload_date)s.%(title)s.%(id)s.%(ext)s"
```
docker-compose example
```
version: '3'
services:
  bot:
    image: vanopiano/download_bot:latest
    restart: on-failure
    env_file: [.env]
    volumes:
      - ./data:/app/data
```

Run:
```sh
  docker-compose up -d
```

### Run in development without docker:
1. Fill .env from .env.sample with your bot token and user
2. Run
```sh
  bundle install
  bundle exec bot.rb
```
