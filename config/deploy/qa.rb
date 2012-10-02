set :deploy_to, "PATH TO YOUR DOMAIN ROOT DIRECTORY"
set :user, "SSH USER NAME"
set :domain, "SERVER IP ADDRESS" 
set :password, "YOUR SUPER SECRET PASSWORD" 
set :port, "22" 
server "#{user}@#{domain}", :app 
set :group, "YOUR GROUP" #www-data, apache, www ....
set :local_path, 'PATH OF YOUR LOCAL DOMAIN DIRECTORY'

# Local Database credentials
set :local_db_database, "DATABASE NAME"
set :local_db_username, "DATABASE USER NAME"
set :local_db_password, "DATABASE PASSWORD"
set :local_db_host, "localhost"
set :local_db_charset, "utf8"
set :local_site_url, "LOCAL DOMAIN URL"
set :db_prefix, 'wp_'

# Remote Database credentials for prod.rb
set :remote_db_database, "DATABASE NAME"
set :remote_db_username, "DATABASE USER NAME"
set :remote_db_password, "DATABASE PASSWORD"
set :remote_db_host, "localhost"
set :remote_db_charset, "utf8"
set :remote_site_url, "DOMAIN URL"

set :dbp, "#{remote_db_database}.#{db_prefix}"


#####################################################################################
# Now Begin the magic
#####################################################################################

#Create backups directory
namespace(:deploy) do
  desc "Add backups directory"
  task :add_backups_dir, :roles => :app do
    run "mkdir #{shared_path}/backups"
  end
end
after "deploy:setup", "deploy:add_backups_dir"

#Create symlink for WP uploads folder
namespace :myproject do
    desc "Create symlink for uploads folder"
    task :symlink, :roles => :app do
        run "ln -nfs #{shared_path}/uploads #{release_path}/wp-content/uploads"
    end
end
after "deploy", "myproject:symlink"

# Backup Remote DB to put it in share/backups
namespace(:db) do
  desc "Backup MySQL Database"
  
  task :backup, :roles => :app do
    run "mysqldump -u#{remote_db_username} -p#{remote_db_password} #{remote_db_database} > #{shared_path}/backups/#{release_name}.sql"
  end

  desc "Restore Mysql DB to the previous one"
  task :rollback, :roles => :app do
    backups = capture("ls -1 #{shared_path}/backups/").split("\n")
    default_backup = backups.last
    puts "Available backups: "
    puts backups
    backup = Capistrano::CLI.ui.ask "Which backup would you like to restore? [#{default_backup}] "
    backup_file = default_backup if backup.empty?

    run "mysql -u#{remote_db_username} -p#{remote_db_password} #{remote_db_database} < #{shared_path}/backups/#{backup_file}"
  end
end
before "db:push", "db:backup"