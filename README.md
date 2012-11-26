# Yet Another Redis-Twitter Clone

## Concept

Build Twitter clone based on:
<http://redis.io/topics/twitter-clone>
to try out integration of various interesting technologies:

### Technologies

- datastore:
  - Redis

- web interface
  - Cuba
  - Coffeescript
  - HAML

- host:
  - Heroku

- datastore persistence
  - postgresql
  - exports / imports via rake tasks

## Schema

    global:nextPostId - <integer>
    global:nextUserId - <integer>
    global:posts - <sorted set or list?> # global timeline of posts
    username:<name>:id - <string> # look up id by username
    user:<id>:name - <string>     # deprecated by above?
    user:<id>:email - <string>    # move to user hash?
    user:<id>:salt - <string>     # move to user hash?
    user:<id>:hashed_password - <string> # move to user hash?

    user:<id>:followers - <list user IDs>
    user:<id>:following - <list user IDs>
    user:<id>:posts - <list, post IDs>

    post:<id>:content - <string>
    post:<id>:user - <string, user ID>
    post:<id>:created_at - <string, create time> # serialize for time zone?

## Models

create `RedisModel` based on <https://github.com/danlucraft/retwis-rb/blob/master/domain.rb>

```
class User < RedisModel
end
class Post < RedisModel
```

## Actions

### /

timeline of posts

`global:posts` - list of post IDs

### /user POST params

create user

### /:username

`:username` user's posts

### /:username/follow

### /:username/unfollow

### /:username/following

### /:username/followers

### /:username/mentions

### /post/:id

### /post POST params

posts a message

## Reference

- <http://redis.io/topics/data-types>
- <http://redis.io/topics/twitter-clone>
- <https://github.com/redis/redis-rb>
- <http://jimneath.org/2011/03/24/using-redis-with-ruby-on-rails.html>
- <https://github.com/danlucraft/retwis-rb>

## Load and benchmark w/ random data

<http://stackoverflow.com/questions/88311/how-best-to-generate-a-random-string-in-ruby>

    [molecule@air] time ruby -e "puts (0...2560000).map{65.+(rand(26)).chr}.join()">/dev/null 
    real	0m2.350s
    [molecule@air] rvm use ruby-1.9.2-p318
    [molecule@air] time ruby -e "puts (0...2560000).map{65.+(rand(26)).chr}.join()">/dev/null  
    real	0m1.513s
