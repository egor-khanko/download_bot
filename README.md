# [YT Download bot](https://github.com/ivan-leschinsky/download_bot/)

[![Docker Image](https://github.com/ivan-leschinsky/download_bot/actions/workflows/docker_image.yml/badge.svg)](https://github.com/ivan-leschinsky/download_bot/actions/workflows/docker_image.yml)
[![Docker latest version](https://img.shields.io/docker/v/vanopiano/download_bot.svg?sort=semver&color=success)](https://hub.docker.com/r/vanopiano/download_bot)
[![Docker Image size](https://img.shields.io/docker/image-size/vanopiano/download_bot.svg?sort=date)](https://hub.docker.com/r/vanopiano/download_bot/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/vanopiano/download_bot.svg)](https://hub.docker.com/r/vanopiano/download_bot)

### Telegram bot to download files with "youtube-dl"-like programs
---
### Run in production with download in separate docker container:
By default downloads runs in `vanopiano/download_ytdl:latest` which can be changed with `DOCKER_IMAGE` variable:


[![Docker latest version](https://img.shields.io/docker/v/vanopiano/download_ytdl.svg?sort=date&color=success)](https://hub.docker.com/r/vanopiano/download_ytdl)
[![Docker Image size](https://img.shields.io/docker/image-size/vanopiano/download_ytdl.svg?sort=date)](https://hub.docker.com/r/vanopiano/download_ytdl/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/vanopiano/download_ytdl.svg)](https://hub.docker.com/r/vanopiano/download_ytdl)

Need to mount `/var/run/docker.sock:/var/run/docker.sock` in order to use this type of run

`.env` example:
```sh
BOT_TOKEN=XXXXXXX
USER_TO_SEND=XXXXXXX
YDL_OPTIONS="--video-multistreams --merge-output-format mp4"
FILE_FORMAT="%(uploader)s/%(upload_date)s.%(title)s.%(id)s.%(ext)s"
DOWNLOAD_DIR=/downloads
DOWNLOAD_IN_DOCKER=false
DOCKER_MOUNT_PATH=/downloads # default
# required, it needs to be absolute path or docker volume
DOCKER_VOLUME=download-volume
DOCKER_IMAGE=vanopiano/download_ytdl:latest # default
DEV=1

```
- `DOWNLOAD_DIR` used as `-P` parameter for yt-dlp, so it can include some path inside mounted dir (`DOCKER_MOUNT_PATH` variable).
- `DOCKER_VOLUME` - volume to mount as `DOCKER_MOUNT_PATH` inside download docker image (`DOCKER_IMAGE`)
---
### Run in production without additional container:
.env example:
```
BOT_TOKEN=XXXXXXX
USER_TO_SEND=XXXXXXX
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

