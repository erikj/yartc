yml_file = 'db/fixtures/demo.yml'

desc "load demo fixtures data from #{yml_file} into database"
task :load do|t|
  puts yml_file
end