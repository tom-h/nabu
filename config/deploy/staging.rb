server '144.6.225.96', :app, :web, :db, :primary => true
set :user, 'ubuntu'

set :unicorn_env, 'staging'

set :branch, 'feature/nabu-593'