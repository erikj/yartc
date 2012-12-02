
task :load_models do
  require 'ohm'
  Ohm.connect
  Dir[ File.join File.expand_path( File.dirname __FILE__ ), '..', '..', 'models', '*.rb' ].each do |model_file|
    require model_file
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
