# [<img src="logo.jpg" width="36" height="36" />](https://github.com/junhoyeo) Threads Client

> Unofficial, Reverse-Engineered Ruby client for Meta's [Threads](https://threads.net).

### Getting Started

To start using **Threads Client**, first add it to your application's Gemfile:

```ruby
gem 'threads_client'
```

Then run `bundle install`.


<summary><h3>🚀 Usage</h3></summary>

#### 🌀 Config Threads

Using **username** and **password** (first time)
```ruby
credentials = {
  username: "Instagram's username",
  password: "Instagram's password"
}

ThreadsClient.config do |config|
  config.credentials = credentials
end
```

Using **usertoken** and **userid** (get from [here](#🤖-get-usertoken-and-userid))
```ruby
credentials = {
  usertoken: "token received after login successfull",
  userid: "Instagram's user id"
}

ThreadsClient.config do |config|
  config.credentials = credentials
end
```

>💡 TIP: Using **usertoken** and **userid** to avoid Theard rate limit and decrease response time.

#### 🤖 Get usertoken and userid

```ruby
  userinfo = ThreadsClient.get_userinfo
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
ThreadsClient.publish(text: 'Hello World!')
```

###### ✨ Threads with Image

###### ✨ Threads with Link Attachment

###### ✨ Reply to Other Threads

###### ✨ Like/Unlike a Thread

###### ✨ Follow/Unfollow a User

###### ✨ Delete a Post
