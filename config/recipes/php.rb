set :shared_children, %w()
set :user, ''
set :group, ''
set :change_ownership, false

# Set of capistrano overrides for PHP projects. Original tasks doesn't 
# make too much sense in PHP. These tasks are project specific and therefore
# are mostly left blank.

namespace :deploy do
  desc <<-DESC
    Migrates the database. 
  DESC
  task :migrate, :roles => :db, :only => { :primary => true } do
  end

  desc <<-DESC
    Sets write permissions on the latest release directory.
  DESC
  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
    run "chown -R #{user}:#{group} #{latest_release}" if fetch(:change_ownership, false)
  end

  desc <<-DESC
    Starts the web server. 
  DESC
  task :start, :roles => :app do
  end

  desc <<-DESC
    Stops the web server.
  DESC
  task :stop, :roles => :app do
  end

  desc <<-DESC
    Restarts the web server.
  DESC
  task :restart, :roles => :app, :except => { :no_release => true } do
  end

  desc <<-DESC
    Sets directory permissions.
  DESC
  task :set_permissions do
    run "chown -R #{user}:#{group} #{deploy_to}" if fetch(:change_ownership, false)
  end

  namespace :web do
    desc <<-DESC
      Disables the application. Most likely you would want to 
      display maintainance message instead of your website.
    DESC
    task :disable, :roles => :web, :except => { :no_release => true } do
    end

    desc <<-DESC
      Enables the application.
    DESC
    task :enable, :roles => :web, :except => { :no_release => true } do
    end
  end
end

after 'deploy:setup', 'deploy:set_permissions'

