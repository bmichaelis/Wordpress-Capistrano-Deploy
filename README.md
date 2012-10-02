# Wordpress Capistrano Deploy #
-------------
This is Wordpress capistrano Deployment recipe that I fork from [Nathaniel](https://github.com/nathanielks) [Wordpress capirtrano Deploy](https://github.com/nathanielks/Wordpress-Capistrano-Deploy). So special thanks to you!


##What is Capistrano?##
-------------
According to [Capistrano official site](https://github.com/capistrano/capistrano), Capistrono is a utility and framework for executing **commands** in parallel on **multiple remote machines**, via **SSH**. Is that mean anything that you on the command line, you can integrate with Capistrano? 

My answer is **YES** ……..let 's get started!


## What you will need on your local machine? ##
-------------
* Ruby RVM
* Capistrano
* railsless-deploy
* capistrano-ext
* mysql
* mysqldump
* rsync
* git
* You are using SSH to access the remote servers.


## What can you do with this recipe? ##
----------------
* Setup releases, shared folders on QA/Production server
* Create current symlink and point to the current release
* Roll back to the previous release (Not only you can roll back files but also you can roll back Database!)
* Sync up wp-content/uploads folder from Local to QA/Prod 
* Sync up wp-content/uploads folder from QA/Prod to Local
* Backup Database on QA/Production from 

*** I'm putting a video tutorial together soon.. Please stay tune! ***

## How to use cap commands?##
-----------------
### QA or Staging ###

	* cap deploy:setup 
	* cap deploy
	* cap deploy:rollback
	* cap db:push
	* cap db:pull
	* cap files:sync_up
	* cap files:sync_down

### Production ###

	* cap prod deploy:setup 
	* cap prod deploy
	* cap prod deploy:rollback
	* cap prod db:push
	* cap prod db:pull
	* cap prod files:sync_up
	* cap prod files:sync_down
