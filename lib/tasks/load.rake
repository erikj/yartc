require 'ohm'

def load_models
  Ohm.connect
  Dir[ File.join File.expand_path( File.dirname __FILE__ ), '..', '..', 'models', '*.rb' ].each do |model_file|
    require model_file
  end
end

yml_file = 'db/fixtures/demo.yml'

desc "load demo fixtures data from #{yml_file} into database"
task :load do

  load_models
  yml = YAML.load_file yml_file

  yml['users'].each do |user_opts|
    # puts user_opts.inspect
    user = User.find(:name=>user_opts['name'], :email=>user_opts['email']).first
    unless user
      user = User.create(user_opts)
      puts "created user: #{user.inspect}"
    end
    # puts user.inspect
  end

  yml['posts'].each do |post_opts|
    # puts post_opts.inspect
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
