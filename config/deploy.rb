set :stages, %w(prod qa)
set :default_stage, "qa"
require 'capistrano/ext/multistage'

set :application, "APPLICATION NAME" 
set :repository, "YOUR GIT REPO LINK" 
set :scm, :git
set :use_sudo, false

ssh_options[:forward_agent] = true
set :deploy_via, :remote_cache
set :copy_exclude, [".git", ".DS_Store", ".gitignore", ".gitmodules"]
set :git_enable_submodules, 0
set :wp_multisite, 0 # TODO Set to 1 if multisite
set :keep_releases, 10

# This is the path to WordPress's uploads folder on YOUR machine
set :uploads_path, "PATH TO UPLOAD FOLDER"


#####################################################################################
# Now Begin the magic
#####################################################################################

#Dump Local DB and push to Remote DB
#Search and Replace local -> Remote URL
namespace(:db) do
  desc "Dump Local DB and replace Remote DB"
  task :push, :roles => :app do
    run_locally "mysqldump --user=#{local_db_username} --password=#{local_db_password} -C -c --skip-add-locks --database #{local_db_database} | ssh #{user}@#{domain} -p #{port} 'mysql -u#{remote_db_username} -p#{remote_db_password} #{remote_db_database}'"
    run "[ -d #{shared_path}/srdb/ ] || git clone git://github.com/interconnectit/Search-Replace-DB.git #{shared_path}/srdb"  
    run "php #{shared_path}/srdb/searchreplacedb2cli.php -h #{remote_db_host} -u #{remote_db_username} -d #{remote_db_database} -p #{remote_db_password} -c #{remote_db_charset} -s '#{local_site_url}' -r '#{remote_site_url}'"
  end

#Dump Remote DB and replace local DB
  desc "Dump Remote DB and replace local DB"
  task :pull, :roles => :app do
    run "mysqldump -u#{remote_db_username} -p#{remote_db_password} #{remote_db_database} > #{shared_path}/backups/#{release_name}.sql"
    run_locally "[ -d db ] || mkdir db"
    run_locally "[ -d srdb ] || git clone git://github.com/interconnectit/Search-Replace-DB.git srdb"  
    run_locally "rsync -avz #{user}@#{domain}:#{shared_path}/backups/* db"
    backups = capture("ls -1 #{shared_path}/backups/").split("\n")
    default_backup = backups.last
    puts "Available backups: "
    puts backups
    backup = Capistrano::CLI.ui.ask "Which backup would you like to restore? [#{default_backup}] "
    run_locally "mysql -u root #{local_db_database} < db/#{default_backup}"
    run_locally "php srdb/searchreplacedb2cli.php --host #{local_db_host} --user #{local_db_username} -d #{local_db_database} --pass #{local_db_password} --charset #{local_db_charset} --search '#{remote_site_url}' --replace '#{local_site_url}'"
  end
end


#Sync uploads folder from local to Remote
namespace(:files) do
  desc "Sync local Uploads folder to Remote folder"
  task :sync_up, :roles => :app do
    run_locally "if [ -d #{uploads_path} ]; then rsync -avhru #{uploads_path} -delete -e 'ssh -p #{port}' #{user}@#{domain}:#{shared_path}; fi"
  end
#Sync uploads folder from Remote to Local  
  desc "Sync remote Uploads folder to local folder"
  task :sync_down, :roles => :app do
  	run_locally "rsync -avz #{user}@#{domain}:#{shared_path}/uploads/* #{uploads_path}"
  end
end