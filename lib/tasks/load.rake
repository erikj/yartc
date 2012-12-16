
task :connect_redis do
  require 'ohm'
  ENV['REDIS_URL'] = ENV['REDISTOGO_URL'] if ENV.has_key? 'REDISTOGO_URL'
  Ohm.connect
end

task :load_models=> :connect_redis do
  Dir[ File.join File.expand_path( File.dirname __FILE__ ), '..', '..', 'models', '*.rb' ].each do |model_file|
    require model_file
  end
end

desc "clear database"
task :clear=>:connect_redis do
  keys = Ohm.redis.keys '*'
  abort "No keys to delete, aborting" if keys.size <= 0
  puts "Are you sure you want to delete all #{keys.size} keys from the database? (yes/no)"
  input = STDIN.gets.strip
  if input == 'yes'
    puts "Deleting..."
    deleted_count = Ohm.redis.del keys
    puts "Deleted #{deleted_count} keys"
  else
    abort 'aborting'
  end
end

yml_file = 'db/fixtures/demo.yml'

desc "load demo fixtures data from #{yml_file} into database"
task :load=>:load_models do

  yml = YAML.load_file yml_file

  yml['users'].each do |user_opts|
    user = User.find(:name=>user_opts['name'], :email=>user_opts['email']).first
    unless user
      user = User.create(user_opts)
      puts "created user: #{user.inspect}"
    end
  end

  yml['posts'].each do |post_opts|
    user = nil
    if post_opts.has_key? 'user'
      user = User.find(:name=>post_opts['user']).first
      post_opts['user'] = user
    end

    if user
      post = Post.create post_opts
      puts "created post: #{post.inspect}"
    end

  end

end
