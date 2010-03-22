set :application, "myproject"
set :default_stage, "dev"
set :scm, :subversion
set :scm_username, 'svnuser'
set :use_sudo, false

default_run_options[:pty] = true

load './config/recipes/php'
require 'capistrano/ext/multistage'
load "./config/recipes/#{application}"

