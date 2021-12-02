#!/usr/bin/env ruby

require 'telegram/bot'
require 'uri'
require 'youtube-dl.rb'
require 'dotenv/load' unless ENV['PRODUCTION'] # for development without docker

DOWNLOAD_DIR = ENV['DOWNLOAD_DIR']
FILE_FORMAT = ENV['FILE_FORMAT']
MERGE_OUTPUT_FORMAT = ENV['MERGE_OUTPUT_FORMAT']

class DownloadJob
  class << self
    def perform_async(link)
      Thread.new { perform(link) }.run
    end

    def perform(link)
      options = {
        path: DOWNLOAD_DIR,
        merge_output_format: MERGE_OUTPUT_FORMAT,
        output: FILE_FORMAT,
        video_multistreams: true
      }

      video = YoutubeDL::Video.new(link, options)
      BotHandler.send_msg("Downloading: \"#{video.information[:title]}\"")

      video.download
      BotHandler.send_msg("Download completed: \"#{video.information[:title]}\"")
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
        DownloadJob.perform_async(message.text)
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
      bot_api.send_message(chat_id: USER_TO_SEND, text: text, disable_web_page_preview: true)
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
