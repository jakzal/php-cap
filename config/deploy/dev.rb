set :domain, 'kuba.dev'
set :user, 'kuba'
set :group, 'apache'
set :env, 'prod'
set :deploy_via, :export
set :deploy_to, "/var/www/kuba.dev"
set :repository,  "svn+ssh://localhost/kuba"
set :symfony_version, '1.4.3'
set :db_user, ""
set :db_pass, ""
set :db_name, ""
set :db_host, ""
set :db_adapter, "" 

role :web, "#{domain}"                   # Your HTTP server, Apache/etc
role :app, "#{domain}"                   # This may be the same as your `Web` server
role :db,  "#{domain}", :primary => true # This is where Rails migrations will run

