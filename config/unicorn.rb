# based on http://blog.railsonfire.com/2012/05/06/Unicorn-on-Heroku.html

worker_processes 3
timeout 30
preload_app true

before_fork do |server, worker|

  if defined?(Ohm)
    Ohm.redis.quit
    # Rails.logger.info('Disconnected from Redis')
  end

  sleep 1
end

after_fork do |server, worker|

  if defined?(Ohm)
    ENV['REDIS_URL'] = ENV['REDISTOGO_URL'] if ENV.has_key? 'REDISTOGO_URL'
    Ohm.connect
  end
end