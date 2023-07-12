# frozen_string_literal: true

require_relative "threads_client_ruby/version"
require 'securerandom'
require 'net/http'
require 'uri'
require 'json'
require 'httparty'
require 'mime/types'

module ThreadsClientRuby
  DEFAULT_DEVICE_ID = "android-#{rand(36**24).to_s(36)}"
  LATEST_ANDROID_APP_VERSION = '289.0.0.77.109'
  BASE_API_URL = 'https://i.instagram.com/api/v1'
  LOGIN_URL = BASE_API_URL + '/bloks/apps/com.bloks.www.bloks.caa.login.async.send_login_request/'
  POST_URL = BASE_API_URL + '/media/configure_text_only_post/'
  POST_WITH_IMAGE_URL = BASE_API_URL + '/media/configure_text_post_app_feed/'
  DEFAULT_LSD_TOKEN = 'NjppQDEgONsU_1LCzrmp6q'
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
      block.call(ThreadsClientRuby::Config)
    else
      ThreadsClientRuby::Config
    end
  end

  def self.get_userinfo
    core = ThreadsClientRuby::Core.new ThreadsClientRuby::Config.credentials
    core.user_info
  end

  # available key for options:
  # - text
  # - image
  # - url
  # - reply_id
  def self.publish(options = {})
    core = ThreadsClientRuby::Core.new ThreadsClientRuby::Config.credentials
    core.publish(options)
  end

  class Core
    def initialize(credentials = {})
      if credentials.is_a?(Hash)
        @username = credentials[:username]
        @password = credentials[:password]
        @user_token = credentials[:usertoken]
        @user_id = credentials[:userid]
      else
        raise "Invalid credentials"
      end
    end

    def publish(options)
      req_post_url = ThreadsClientRuby::POST_URL
      data = default_req_params(options)
      if options[:image]
        req_post_url = ThreadsClientRuby::POST_WITH_IMAGE_URL
        data = req_params_with_image(data, options[:image])
      else
        data[:publish_mode] = 'text_post'
      end
      if options[:url] || options[:reply_id]
        data[:text_post_app_info] = {}
        data[:text_post_app_info][:link_attachment_url] = options[:url] if options[:url]
        data[:text_post_app_info][:reply_id] = options[:reply_id] if options[:reply_id]
      end
      url = URI.parse(req_post_url)
      headers = get_app_headers
      payload = "signed_body=SIGNATURE.#{URI.encode_www_form_component(JSON.generate(data))}"
      response = HTTParty.post(url, headers: headers, body: payload)
      p response_handler(response)
    end

    def user_info
      { usertoken: user_token, userid: user_id }
    end

    private

    def default_req_params(options)
      now = Time.now
      timezone_offset = -now.utc_offset
      {
        text_post_app_info: { reply_control: 0 },
        timezone_offset: timezone_offset.to_s,
        source_type: '4',
        _uid: user_id,
        device_id: DEFAULT_DEVICE_ID,
        caption: options[:text] || '',
        upload_id: now.to_i,
        device: androidDevice
      }
    end

    def req_params_with_image(data, image)
      upload_id = Time.now.to_i.to_s
      upload_image(image, upload_id)
      data[:upload_id] = upload_id
      data[:scene_capture_type] = ''
      data
    end

    def androidDevice
      {
        manufacturer: 'OnePlus',
        model: 'ONEPLUS+A3010',
        os_version: 25,
        os_release: '7.1.1'
      }
    end

    def user_token
      @user_token ||= req_login_n_get_token
    end

    def user_id
      @user_id ||= req_get_user_id
    end

    def get_app_headers
      app_version = ThreadsClientRuby::LATEST_ANDROID_APP_VERSION
      headers = {
        'User-Agent' => "Barcelona #{app_version} Android",
        'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8'
      }
      headers['Authorization'] = "Bearer IGT:2:#{@user_token}" if @user_token
      headers
    end

    def get_default_headers(username = nil)
      app_headers = get_app_headers
      headers = {
        'authority' => 'www.threads.net',
        'accept' => '*/*',
        'accept-language' => 'ko',
        'cache-control' => 'no-cache',
        'origin' => 'https://www.threads.net',
        'pragma' => 'no-cache',
        'Sec-Fetch-Site' => 'same-origin',
        'x-asbd-id' => '129477',
        'x-fb-lsd' => @lsd_token || ThreadsClientRuby::DEFAULT_LSD_TOKEN,
        'x-ig-app-id' => '238260118697367'
      }
      headers['referer'] = "https://www.threads.net/@#{username}" if username
      app_headers.merge(headers)
    end

    def req_login_n_get_token
      client_input_params = {
        password: @password,
        contact_point: @username,
        device_id: ThreadsClientRuby::DEFAULT_DEVICE_ID
      }
      server_params = {
        credential_type: 'password',
        device_id: ThreadsClientRuby::DEFAULT_DEVICE_ID
      }
      params = URI.encode_www_form_component(JSON.generate({
        client_input_params: client_input_params,
        server_params: server_params
      }))
      blockVersion = '5f56efad68e1edec7801f630b5c122704ec5378adbee6609a448f105f34a9c73'
      bkClientContext = URI.encode_www_form_component(JSON.generate({
        bloks_version: blockVersion,
        styles_id: 'instagram'
      }))
      url = URI.parse(ThreadsClientRuby::LOGIN_URL)
      headers = get_app_headers
      response = HTTParty.post(url, headers: headers, body: "params=#{params}&bk_client_context=#{bkClientContext}&bloks_versioning_id=#{blockVersion}")
      data = response.body
      data.scan(/Bearer IGT:2:(.*?)"/).flatten.first&.gsub('\\', '')
    end

    def req_get_user_id
      url = "https://www.instagram.com/#{@username}"
      headers = get_default_headers(@username).merge({
        'accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'accept-language' => 'ko,en;q=0.9,ko-KR;q=0.8,ja;q=0.7',
        'Authorization' => nil,
        'referer' => 'https://www.instagram.com/',
        'sec-fetch-dest' => 'document',
        'sec-fetch-mode' => 'navigate',
        'sec-fetch-site' => 'cross-site',
        'sec-fetch-user' => '?1',
        'upgrade-insecure-requests' => '1',
        'x-asbd-id' => nil,
        'x-fb-lsd' => nil,
        'x-ig-app-id' => nil
      })
      options = {
        headers:  headers
      }
      response = HTTParty.get(url, options)
      text = response.body
      text.gsub!(/\s/, '') # remove ALL whitespaces from text
      text.gsub!(/\n/, '') # remove all newlines from text

      user_id = text.match(/"user_id":"(\d+)"/)&.captures&.first 
      @lsd_token = text.match(/"LSD",\[\],{"token":"(\w+)"},\d+\]/)&.captures&.first
      user_id
    end

    def response_handler(response)
      return { status: false, code:  response.code } if response.code != 200

      response_body = JSON.parse(response.body)
      { status: true, response_body: response_body }
    end

    def upload_image(image, upload_id)
      name = "#{upload_id}_0_#{SecureRandom.random_number(10**10 - 10**9 + 1) + 10**9}"
      url = "https://www.instagram.com/rupload_igphoto/#{name}"
    
      content = nil
      mime_type = nil
    
      if image.is_a?(String) || image.key?(:path)
        image_path = image.is_a?(String) ? image : image[:path]
        is_file_path = !image_path.start_with?('http')
    
        if is_file_path
          content = File.binread(image_path)
          mime_type = MIME::Types.type_for(image_path).first.to_s
        else
          image_uri = URI.parse(image_path)
          response = Net::HTTP.get_response(image_uri)
          if response.is_a?(Net::HTTPSuccess)
            content = response.body
            mime_type = response['content-type']
          end 
        end
      else
        content = image[:data]
        mime_type = image[:type].include?('/') ? image[:type] : MIME::Types.type_for(image[:type]).first.to_s
      end
    
      x_instagram_rupload_params = {
        upload_id: upload_id,
        media_type: '1',
        sticker_burnin_params: JSON.generate([]),
        image_compression: JSON.generate({ lib_name: 'moz', lib_version: '3.1.m', quality: '80' }),
        xsharing_user_ids: JSON.generate([]),
        retry_context: JSON.generate({
          num_step_auto_retry: '0',
          num_reupload: '0',
          num_step_manual_retry: '0',
        }),
        'IG-FB-Xpost-entry-point-v2': 'feed',
      }
    
      content_length = content.length
      image_headers = get_default_headers(@username).merge({
        'Content-Type': 'application/octet-stream',
        'X_FB_PHOTO_WATERFALL_ID': SecureRandom.uuid,
        'X-Entity-Type': mime_type ? "image/#{mime_type}" : 'image/jpeg',
        'Offset': '0',
        'X-Instagram-Rupload-Params': JSON.generate(x_instagram_rupload_params),
        'X-Entity-Name': name,
        'X-Entity-Length': content_length.to_s,
        'Content-Length': content_length.to_s,
        'Accept-Encoding': 'gzip',
      })
    
      begin
        response = Net::HTTP.start(URI(url).hostname, URI(url).port, use_ssl: true) do |http|
          request = Net::HTTP::Post.new(URI(url).request_uri, image_headers)
          request.body = content
          http.request(request)
        end
    
        data = JSON.parse(response.body)
        data
      rescue StandardError => e
        puts "[UPLOAD_IMAGE] FAILED: #{e.response.body}"
        raise e
      end
    end
  end
end

 # ThreadsClientRuby.publish(text: 'Hello World!', image: '/Users/quan/Products/threads-api/logo.jpg')