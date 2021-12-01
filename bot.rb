#!/usr/bin/env ruby

require 'telegram/bot'
require 'sucker_punch'
require 'json'
require 'open3'
require 'uri'

require 'dotenv/load' unless ENV['PRODUCTION'] # for development without docker

DOWNLOAD_DIR = ENV['DOWNLOAD_DIR']
FILE_FORMAT = ENV['FILE_FORMAT']
YDL_PATH = ENV['YDL_PATH']
YDL_OPTIONS = ENV['YDL_OPTIONS']
TELEGRAM_MAX_LENGTH = 4096

SuckerPunch.shutdown_timeout = ENV['BACKGROUND_JOB_MAX_TIME'] || 600

class DownloadJob
  include SuckerPunch::Job
  workers 3

  def perform(link)
    title = fetch_info(link)
    BotHandler.send_msg("Downloading... \"#{title}\"")

    command = "#{YDL_PATH} -o '#{FILE_FORMAT}' #{YDL_OPTIONS} -P '#{DOWNLOAD_DIR}' #{link}"

    Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
      error_text = stderr.read
      exit_code = wait_thr.value
      if error_text.empty?
        BotHandler.send_msg("Download completed:\n #{stdout.read}")
      else
        BotHandler.send_msg("Something went wrong while downloading:\n #{error_text}")
      end
    end
  end

  def fetch_info(link)
    JSON.parse(`#{YDL_PATH} -j #{link}`)['title']
  rescue
    nil
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
      texts_array = text.scan /.{1,#{TELEGRAM_MAX_LENGTH}}/

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
