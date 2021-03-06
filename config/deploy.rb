# config valid only for Capistrano 3.1
lock '3.4.0'

set :application, 'temple'

set :repo_url, 'git@gitlab.com:Almaron/temple.git'

set :user,  'malk'

set :default_stage,     'staging'

set :current_path,      File.join(deploy_to, 'current')
set :use_sudo,          false

set :linked_files, %w{ config/database.yml config/secrets.yml  config/settings.yml config/journals.yml }

set :linked_dirs, %w{ log tmp/pids tmp/cache tmp/sockets public/system public/uploads }

set :rvm_ruby_version, '2.2.4@temple'
# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

set :keep_releases, 8

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
