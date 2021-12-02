#!/usr/bin/env ruby

require 'telegram/bot'
require 'json'
require 'open3'
require 'uri'
require 'dotenv/load' unless ENV['PRODUCTION'] # for development without docker

DOWNLOAD_DIR = ENV['DOWNLOAD_DIR']
FILE_FORMAT = ENV['FILE_FORMAT']
YDL_OPTIONS = ENV['YDL_OPTIONS']
YDL_PATH = ENV.fetch('YDL_PATH', 'youtube-dl')

class DownloadJob
  class << self
    def perform_async(link)
      Thread.new { perform(link) }.run
    end

    def perform(link)
      title = JSON.parse(`#{YDL_PATH} -j #{link}`)['title']
      BotHandler.send_msg("Downloading \"#{title}\"")

      command = "#{YDL_PATH} -o '#{FILE_FORMAT}' #{YDL_OPTIONS} -P '#{DOWNLOAD_DIR}' #{link}"

      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        error_text = stderr.read

        if error_text.empty?
          BotHandler.send_msg("Download completed for \"#{title}\"")
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
