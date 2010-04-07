set :shared_children, shared_children + %w(dump)

namespace :mysql do
  task :dump_and_download, :roles => :db do
    file_path = dump
    dump_local_path = fetch(:db_dump_local_path, "dump")
    FileUtils.mkdir_p dump_local_path
    download file_path, File.join(dump_local_path, File.basename(file_path))
  end

  task :dump, :roles => :db do
    file_name = "#{db_name}-"+Time.now.utc.strftime("%Y%m%d%H%M%S")+".sql"
    file_path = fetch(:db_dump_path, File.join(shared_path, "dump"))
    file_path = File.join(file_path, file_name)

    run "mysqldump -u #{db_user} -h #{db_host} -p#{db_pass} #{db_name} > #{file_path}"
    run "gzip #{file_path}" 

    file_path+".gz"
  end
end

depend :remote, :command, "mysqldump"
depend :remote, :command, "gzip"

