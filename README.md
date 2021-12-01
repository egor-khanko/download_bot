# [YT Download bot](https://github.com/ivan-leschinsky/download_bot/)

[![Docker Image Build](https://github.com/ivan-leschinsky/download_bot/actions/workflows/docker-image.yml/badge.svg)](https://github.com/ivan-leschinsky/download_bot/actions/workflows/docker-image.yml)

### Telegram bot to download files with "youtube-dl"-like programs


### Run in production:
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
