# YT Download bot

[![Docker Image CI](https://github.com/ivan-leschinsky/download_bot/actions/workflows/docker-image.yml/badge.svg)](https://github.com/ivan-leschinsky/download_bot/actions/workflows/docker-image.yml)

### Telegram bot to download files wih "youtube-dl"-like programs

Select youtube-dl, I like this one: https://github.com/yt-dlp/yt-dlp

### Run in production:
1. Fill .env from .env.sample with your bot token and user

```sh
  docker-compose up -d
```

### Run in development:
1. Fill .env from .env.sample with your bot token and user

```sh
  bundle install
  bundle exec bot.rb
```
