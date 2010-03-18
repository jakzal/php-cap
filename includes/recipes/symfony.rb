set :shared_children, shared_children + %w(log uploads)
set :symfony_version, '1.4.3'
set :php_command, 'php -d memory_limit=512M'
set :env, 'prod'
set :db_adapter, 'pgsql'
set :db_host, 'localhost'
set :db_user, ''
set :db_pass, ''
set :remove_dev_controllers, true

namespace :symfony do
  desc <<-DESC
    Builds symfony application.
  DESC
  task :finalize_update do
    create_symlinks
    configure
    normalize_asset_timestamps
    publish_assets
    build_classes
    clear_controllers
    clear_cache
    set_permissions
  end

  desc <<-DESC
    Configures the symfony application.
  DESC
  task :configure do
    configure_database
  end

  desc <<-DESC
    Configures the database.
  DESC
  task :configure_database do
    run <<-CMD
      #{latest_release}/symfony configure:database '#{db_adapter}:host=#{db_host};dbname=#{db_name}' #{db_user} #{db_pass};
      #{latest_release}/symfony configure:database --env=#{env} '#{db_adapter}:host=#{db_host};dbname=#{db_name}' #{db_user} #{db_pass};
    CMD
  end

  desc <<-DESC
    Creates symbolic links to shared directories.
  DESC
  task :create_symlinks do
    run <<-CMD
      rm -f #{latest_release}/web/sf && rm -f #{latest_release}/lib/vendor/symfony &&
      rm -rf #{latest_release}/web/uploads && rm -rf #{latest_release}/log &&
      ln -s #{shared_path}/log #{latest_release}/log &&
      ln -s #{shared_path}/uploads #{latest_release}/web/uploads &&
      ln -s #{shared_path}/symfony-#{symfony_version} #{latest_release}/lib/vendor/symfony &&
      ln -s #{latest_release}/lib/vendor/symfony/data/web/sf #{latest_release}/web/sf
    CMD
  end

  desc <<-DESC
    Touches all asset files so that times are consistent.
  DESC
  task :normalize_asset_timestamps do
    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = %w(images js css).map { |p| "#{latest_release}/web/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
    end
  end

  desc <<-DESC
    Publishes project assets.
  DESC
  task :publish_assets do
    run "#{php_command} #{latest_release}/symfony plugin:publish-assets"
  end

  desc <<-DESC
    Builds doctrine model, form and filter classes.
  DESC
  task :build_classes do
    run "#{php_command} #{latest_release}/symfony doctrine:build --all-classes"
  end

  desc <<-DESC
    Removes development controllers.
  DESC
  task :clear_controllers do
    run "#{php_command} #{latest_release}/symfony project:clear-controllers" if fetch(:remove_dev_controllers, true)
  end

  desc <<-DESC
    Clears cache.
  DESC
  task :clear_cache do
    run "#{php_command} #{latest_release}/symfony cc"
  end

  desc <<-DESC
    Fixes file permissions.
  DESC
  task :set_permissions do
    run "#{php_command} #{latest_release}/symfony project:permissions"
  end

  desc <<-DESC
    Downloads symfony and unpacks it to shared directory.
  DESC
  task :get_symfony do
    run <<-CMD
      cd #{shared_path}; wget -q http://www.symfony-project.org/get/symfony-#{symfony_version}.tgz;
      cd #{shared_path}; tar xzf symfony-#{symfony_version}.tgz;
      rm -f #{shared_path}/symfony-#{symfony_version}.tgz;
    CMD
  end

  desc <<-DESC
    Migrates the symfony project.
  DESC
  task :migrate do 
    run "#{php_command} #{latest_release}/symfony doctrine:migrate --env=#{env}"
  end

  namespace :web do
    desc <<-DESC
      Enables symfony project.
    DESC
    task :enable do
      project_path = previous_release ? current_path : latest_release
      run "#{php_command} #{project_path}/symfony project:enable #{env}"
    end

    desc <<-DESC
      Disables symfony project.
    DESC
    task :disable do
      project_path = previous_release ? current_path : latest_release
      run "#{php_command} #{project_path}/symfony project:disable #{env}"
    end
  end
end

before 'deploy:finalize_update', 'symfony:finalize_update'
before 'deploy:set_permissions', 'symfony:get_symfony'
before 'deploy:migrate', 'deploy:web:disable'
after 'deploy:migrate', 'deploy:web:enable'
after 'deploy:migrate', 'symfony:migrate'
after 'deploy:web:enable', 'symfony:web:enable'
after 'deploy:web:disable', 'symfony:web:disable'

