require 'threads_client/core'
require 'httparty'
module ThreadsClient
  class Error < StandardError; end
  module Config
    class << self
      attr_accessor :credentials # It's hash, with keys: username, password, usertoken, userid
      def setup
        @credentials = credentials
      end
    end
    self.setup
  end

  def self.config(&block)
    if block_given?
      block.call(ThreadsClient::Config)
    else
      ThreadsClient::Config
    end
  end

  def self.get_userinfo
    core = ThreadsClient::Core.new ThreadsClient::Config.credentials
    core.user_info
  end

  def self.publish(options = {})
    core = ThreadsClient::Core.new ThreadsClient::Config.credentials
    if options[:text] && options[:image]
    elsif options[:text]
      core.publish(options)
    elsif options[:image]
    else
      raise Error.new "Don't have text or image"
    end
  end
end


