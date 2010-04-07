set :shared_children, shared_children + %w(tmp tmp/cache images)
set :php_command, 'php -d memory_limit=512M'
set :db_adapter, 'pgsql'
set :db_host, 'localhost'
set :db_user, ''
set :db_pass, ''

namespace :cakephp do
  task :finalize_update do
    create_symlinks
    configure
    normalize_asset_timestamps
  end

  task :configure do
    configure_database
  end

  task :configure_database do
    database_config = latest_release+"/app/config/database.php"
    run "sed -i \"s#\\(.*driver.*\\)=>\\(.*\\)'.*'#\\1=>\\2'#{db_adapter}'#\" #{database_config}"
    run "sed -i \"s#\\(.*host.*\\)=>\\(.*\\)'.*'#\\1=>\\2'#{db_host}'#\" #{database_config}"
    run "sed -i \"s#\\(.*login.*\\)=>\\(.*\\)'.*'#\\1=>\\2'#{db_user}'#\" #{database_config}"
    run "sed -i \"s#\\(.*password.*\\)=>\\(.*\\)'.*'#\\1=>\\2'#{db_pass}'#\" #{database_config}"
    run "sed -i \"s#\\(.*database.*\\)=>\\(.*\\)'.*'#\\1=>\\2'#{db_name}'#\" #{database_config}"
  end

  task :create_symlinks do
    run <<-CMD
      rm -rf #{latest_release}/app/tmp && rm -rf #{latest_release}/app/images &&
      ln -s #{shared_path}/tmp #{latest_release}/app/tmp && 
      ln -s #{shared_path}/images #{latest_release}/app/webroot/images
    CMD
  end

  desc <<-DESC
    Touches all asset files so that times are consistent.
  DESC
  task :normalize_asset_timestamps do
    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = %w(images js css img).map { |p| "#{latest_release}/app/webroot/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
    end
  end
end

before 'deploy:finalize_update', 'cakephp:finalize_update'

