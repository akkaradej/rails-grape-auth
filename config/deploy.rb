require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
# require 'mina/rvm'    # for rvm support. (http://rvm.io)
# require 'mina_sidekiq/tasks' # for sidekiq
require 'yaml'

deploy = YAML.load(File.read('config/deploy.yml'))[ENV['on']]

set :domain, deploy['domain']
set :user, deploy['user']
set :deploy_to, deploy['deploy_to']
set :repository, deploy['repository']
set :branch, ENV['branch'] || deploy['branch']
set :rails_env, deploy['rails_env']
set :app_path, lambda { "#{deploy_to}/#{current_path}" }

# override to remove --binstubs
set :bundle_options, lambda { %{--without development test --path "#{bundle_path}" --deployment} }

# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'log', 'public/uploads'
  'angular/node_modules', 'angular/bower_components']

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-1.9.3-p125@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  # sidekiq needs a place to store its pid file
  # queue! %[mkdir -p "#{deploy_to}/shared/pids"]
  # queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/pids"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]

  queue! %[touch "#{deploy_to}/shared/config/secrets.yml"]
  queue  %[echo "-----> Be sure to edit 'shared/config/secrets.yml'."]

  # public
  queue! %[mkdir -p "#{deploy_to}/shared/public"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public"]

  # uploads dir
  queue! %[mkdir -p "#{deploy_to}/shared/public/uploads"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/uploads"]

  # front-end dependencies
  queue! %[mkdir -p "#{deploy_to}/shared/angular"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/angular"]

  queue! %[mkdir -p "#{deploy_to}/shared/angular/node_modules"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/angular/node_modules"]

  queue! %[mkdir -p "#{deploy_to}/shared/angular/bower_components"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/angular/bower_components"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # for sidekiq
    # invoke :'sidekiq:quiet'

    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    # invoke :'angular:deploy'

    to :launch do
      # restart app server
      queue "mkdir -p #{app_path}/tmp"
      queue "touch #{app_path}/tmp/restart.txt"

      # for sidekiq
      # invoke :'sidekiq:restart'
    end

  end
end

task :log do
  queue "tail -f #{deploy_to}/#{shared_path}/log/#{rails_env}.log"
end

task :seed do
  queue "cd #{app_path}; bundle exec rake db:seed"
end

namespace :angular do
  task :deploy do
    queue "cd angular; sudo npm install"
    queue "cd angular; bower install"
    queue "cd angular; grunt build"
  end
end

namespace :bower do 
  task :install do
    queue "cd #{app_path}/public ; bower install"
  end
end

namespace :nginx do 
  task :restart do
    queue "sudo service nginx restart"
  end
end