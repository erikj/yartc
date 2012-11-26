# redis-twitter-clone

## Idea

Build Twitter clone based on:
<http://redis.io/topics/twitter-clone>

### Technologies

- datastore:
  - Redis

- web interface
  - Cuba
  - Coffeescript
  - HAML

## Schema

    global:nextPostId - <integer>
    global:nextUserId - <integer>
    username:<name>:id - <string> # look up id by username
    user:<id>:name - <string>     # deprecated by above?
    user:<id>:email - <string>    # move to user hash?
    user:<id>:salt - <string>     # move to user hash?
    user:<id>:hashed_password - <string> # move to user hash?

    user:<id>:followers - <list user IDs>
    user:<id>:following - <list user IDs>
    user:<id>:posts - <list, post IDs>

    post:<id>(:content?) - <string>, format: "<user-id>|<time>|content", or JSON?
    global:posts - <sorted set or list?> # global timeline of posts

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

> Warning: consider KEYS as a command that should only be used in production environments with extreme care. It may ruin performance when it is executed against large databases. This command is intended for debugging and special operations, such as changing your keyspace layout. Don't use KEYS in your regular application code. If you're looking for a way to find keys in a subset of your keyspace, consider using sets. - <http://redis.io/commands/keys>

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
