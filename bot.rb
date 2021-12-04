#!/usr/bin/env ruby

require 'telegram/bot'
require 'json'
require 'open3'
require 'uri'
require 'dotenv/load' unless ENV['PRODUCTION'] # for development without docker

FILE_FORMAT = ENV['FILE_FORMAT']
YDL_OPTIONS = ENV['YDL_OPTIONS']
DOWNLOAD_IN_DOCKER = ENV['DOWNLOAD_IN_DOCKER'] == 'true'
DOCKER_VOLUME = ENV['DOCKER_VOLUME']
DOCKER_MOUNT_PATH = ENV['DOCKER_MOUNT_PATH'] || '/downloads'
DOCKER_IMAGE = ENV['DOCKER_IMAGE'] || 'vanopiano/download_ytdl:latest'

DOWNLOAD_DIR = ENV['DOWNLOAD_DIR'] || (DOWNLOAD_IN_DOCKER ? '/downloads' : './data')

YDL_PATH = ENV.fetch('YDL_PATH', 'youtube-dl')

TELEGRAM_MAX_LENGTH = 4096

class DownloadJob
  class << self
    def perform_async(link)
      Thread.new { perform(link) }.run
    end

    def perform(link)
      video_data = JSON.parse(`#{YDL_PATH} -j #{link}`)
      title = video_data['title']

      BotHandler.send_msg("Downloading \"#{title}\"")

      options = "-o '#{FILE_FORMAT}' #{YDL_OPTIONS} -P '#{DOWNLOAD_DIR}' #{link}"

      base_command = YDL_PATH
      if DOWNLOAD_IN_DOCKER
        base_command = "docker run -d --rm --name ydl_#{video_data['id']} "\
                       "-v #{DOCKER_VOLUME}:#{DOCKER_MOUNT_PATH} #{DOCKER_IMAGE} #{YDL_PATH}"
      end

      puts "#{base_command} #{options}" unless ENV['PRODUCTION']

      Open3.popen3("#{base_command} #{options}") do |stdin, stdout, stderr, wait_thr|
        error_text = stderr.read

        if error_text.empty?
          if DOWNLOAD_IN_DOCKER
            BotHandler.send_msg("Download started in Docker for \"#{title}\"")
          else
            BotHandler.send_msg("Download completed for \"#{title}\"")
          end
        else
          BotHandler.send_msg("Something went wrong while downloading:\n #{error_text}")
        end
      end
    end
  end
end

class BotHandler
  USER_TO_SEND = ENV['USER_TO_SEND'].to_i

  class << self

    def run
      bot.listen { |message| respond(message) }
    end

    def handle(message)
      if message.text.include?('youtu') && message.text =~ URI::regexp
        DownloadJob.perform(message.text)
      else
        send_msg('I can download only from YouTube')
      end
    end

    def respond(message)
      if message.chat.id == USER_TO_SEND
        handle(message)
      else
        # unknown user
        bot_api.send_message(chat_id: message.chat.id, text: ['🤷‍♀️', '🤷‍♂️', '🎅'].sample)
      end
    end

    def send_msg(text)
      texts_array = text.scan /.{1,#{TELEGRAM_MAX_LENGTH}}/
      # to allow sending large text
      texts_array.each do |small_text|
        bot_api.send_message(chat_id: USER_TO_SEND, text: small_text, disable_web_page_preview: true)
      end
    end

    def bot
      Thread.current[:telegram_bot] ||= Telegram::Bot::Client.new(ENV['BOT_TOKEN'])
    end

    def bot_api
      bot.api
    end
  end
end

BotHandler.run
