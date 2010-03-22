set :shared_children, shared_children + %w(log files dump)

namespace :drupal do
  task :finalize_update do
    create_symlinks
    configure_database
  end
  
  task :create_symlinks do
    run <<-CMD
      rm -rf #{latest_release}/web/sites/default/files && ln -s #{shared_path}/files #{latest_release}/web/sites/default/files &&
      rm -rf #{latest_release}/log && ln -s #{shared_path}/log #{latest_release}/log
    CMD
  end

  task :configure_database do
    run "sed -i \"s#\\$db_url = '.*';#\\$db_url = '#{db_adapter}://#{db_user}:#{db_pass}@#{db_host}/#{db_name}';#\" #{latest_release}/web/sites/default/settings.php"
  end
end

before 'deploy:finalize_update', 'drupal:finalize_update'

