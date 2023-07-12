# [<img src="logo.jpg" width="36" height="36" />](https://github.com/junhoyeo) Threads Client Ruby

> Unofficial, Reverse-Engineered Ruby client for Meta's [Threads](https://threads.net).

# Getting Started

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'threads_client_ruby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install threads_client_ruby

## Usage
#### 🌀 Config Threads

Using **username** and **password** (first time)
```ruby
credentials = {
  username: "Instagram's username",
  password: "Instagram's password"
}

ThreadsClientRuby.config do |config|
  config.credentials = credentials
end
```

Using **usertoken** and **userid** (get from [here](#🤖-get-usertoken-and-userid))
```ruby
credentials = {
  usertoken: "token received after login successfull",
  userid: "Instagram's user id"
}

ThreadsClientRuby.config do |config|
  config.credentials = credentials
end
```

>💡 TIP: Using **usertoken** and **userid** to avoid Theard rate limit and decrease response time.

#### 🤖 Get usertoken and userid

```ruby
  userinfo = ThreadsClientRuby.get_userinfo
  # {
  #   :usertoken=> "eyJkc191c2VyX2lkIjoiNTgzOTIyMTY....",
  #   :userid=>"583922..."
  # }
```

#### 📌 Features

- [x] ✅ [Text Threads](#✨-threads-with-image)
- [ ] ✅ [Threads with Image](#✨-threads-with-image)
- [ ] ✅ [Threads with Link Attachment](#✨-threads-with-link-attachment)
- [ ] ✅ [Reply to Other Threads](#✨-reply-to-other-threads)
- [ ] ✅ [Like/Unlike a Thread](#✨-likeunlike-a-thread)
- [ ] ✅ [Follow/Unfollow a User](#✨-followunfollow-a-user)
- [ ] ✅ [Delete a Post](#✨-delete-a-post)

**✨ Text Threads**

```ruby
ThreadsClientRuby.publish(text: 'Hello World!')
```

###### ✨ Threads with Image

###### ✨ Threads with Link Attachment

###### ✨ Reply to Other Threads

###### ✨ Like/Unlike a Thread

###### ✨ Follow/Unfollow a User

###### ✨ Delete a Post

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/threads_client_ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/threads_client_ruby/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ThreadsClientRuby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/threads_client_ruby/blob/master/CODE_OF_CONDUCT.md).
