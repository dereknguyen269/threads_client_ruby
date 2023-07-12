require 'net/http'
require 'uri'
require 'json'

module ThreadsClient
  DEFAULT_DEVICE_ID = "android-#{rand(36**24).to_s(36)}"
  LATEST_ANDROID_APP_VERSION = '289.0.0.77.109'
  BASE_API_URL = 'https://i.instagram.com/api/v1'
  LOGIN_URL = BASE_API_URL + '/bloks/apps/com.bloks.www.bloks.caa.login.async.send_login_request/'
  POST_URL = BASE_API_URL + '/media/configure_text_only_post/'
  DEFAULT_LSD_TOKEN = 'NjppQDEgONsU_1LCzrmp6q'
  class Core
    def initialize(credentials)
      @username = credentials[:username]
      @password = credentials[:password]
      @user_token = credentials[:usertoken]
      @user_id = credentials[:userid]
    end

    def publish(options)
      now = Time.now
      timezone_offset = -now.utc_offset

      data = {
        text_post_app_info: { reply_control: 0 },
        timezone_offset: timezone_offset.to_s,
        source_type: '4',
        _uid: user_id,
        device_id: DEFAULT_DEVICE_ID,
        caption: options[:text] || 'Please enter the text',
        upload_id: now.to_i,
        device: androidDevice
      }
      data[:publish_mode] = 'text_post'
      url = URI.parse(ThreadsClient::POST_URL)
      headers = get_app_headers
      payload = "signed_body=SIGNATURE.#{URI.encode_www_form_component(JSON.generate(data))}"
      response = HTTParty.post(url, headers: headers, body: payload)
      p response_handler(response)
    end

    def user_info
      { usertoken: user_token, userid: user_id }
    end

    private

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
      app_version = ThreadsClient::LATEST_ANDROID_APP_VERSION
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
        'x-fb-lsd' => @lsd_token || ThreadsClient::DEFAULT_LSD_TOKEN,
        'x-ig-app-id' => '238260118697367'
      }
      headers['referer'] = "https://www.threads.net/@#{username}" if username
      app_headers.merge(headers)
    end

    def req_login_n_get_token
      client_input_params = {
        password: @password,
        contact_point: @username,
        device_id: ThreadsClient::DEFAULT_DEVICE_ID
      }
      server_params = {
        credential_type: 'password',
        device_id: ThreadsClient::DEFAULT_DEVICE_ID
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
      url = URI.parse(ThreadsClient::LOGIN_URL)
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
  end
end
