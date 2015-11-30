#
# Cookbook Name:: pp
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

####basic packages
%w(curl wget git-core zlib1g-dev libssl-dev libxml2-dev libxslt1-dev).each do |pkg|
  package pkg
end

bash "install rvm" do
	code "curl -sSL https://get.rvm.io | bash -s stable"
end

script "source profile" do
  interpreter "bash"
  user "root"
  code <<-EOH
        echo 'export rvm_max_time_flag=60' >> /etc/rvmrc
        source /etc/rvmrc
        source /etc/profile.d/rvm.sh
  EOH
end

####packages for project
%w(ffmpegthumbnailer libx264-dev libmagickwand-dev imagemagick).each do |pkg|
	package pkg
end

directory node[:project][:home] do
	user "nitesh"
	group "nitesh"
	recursive true
end

####git commands
git node[:project][:home] do
	repository node[:project][:repository]
	revision "master"
	timeout 2400
	action :sync
end

%w(libcurl4-openssl-dev apache2-threaded-dev libapr1-dev libaprutil1-dev libcurl4-gnutls-dev).each do |pkg|
	package pkg
end

execute "ruby_install" do
	user "nitesh"
	command "/usr/local/rvm/bin/rvm install 1.9.3"
	command "/usr/local/rvm/bin/rvm use 1.9.3"
end

gem_package "bundler"
# gem_package "passenger" do
#     gem_binary "/usr/local/rvm/rubies/ruby-1.9.3-p551/bin/gem"
#     action :install
# end

execute "passenger_gem" do
	environment ({'PATH' => '/usr/local/rvm/gems/ruby-1.9.3-p551/bin:/usr/local/rvm/gems/ruby-1.9.3-p551@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p551/bin:/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games', 'GEM_PATH' => '/usr/local/rvm/gems/ruby-1.9.3-p551:/usr/local/rvm/gems/ruby-1.9.3-p551@global', 'HOME' => '/home/nitesh', 'USER' => 'nitesh'})
	command "/usr/local/rvm/rubies/ruby-1.9.3-p551/bin/gem install passenger"
end

execute "bundle install" do
	cwd node[:project][:home]
	environment ({'PATH' => '/usr/local/rvm/gems/ruby-1.9.3-p551/bin:/usr/local/rvm/gems/ruby-1.9.3-p551@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p551/bin:/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games', 'GEM_PATH' => '/usr/local/rvm/gems/ruby-1.9.3-p551:/usr/local/rvm/gems/ruby-1.9.3-p551@global', 'HOME' => '/home/nitesh', 'USER' => 'nitesh'}) 
end

execute "passenger_module" do
  command   "passenger-install-apache2-module --auto"
end

template "/etc/apache2/sites-available/local-hsplanner.conf" do
	source "local-hsplanner.erb"
	user "root"
	group "root"
end

execute "enable hsp site" do
	command "cd /etc/apache2/sites-available && sudo a2ensite local-hsplanner.conf"
	cwd node[:project][:home]
end

execute "passenger start" do
	cwd node[:project][:home]
	environment ({'PATH' => '/usr/local/rvm/gems/ruby-1.9.3-p551/bin:/usr/local/rvm/gems/ruby-1.9.3-p551@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p551/bin:/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games', 'GEM_PATH' => '/usr/local/rvm/gems/ruby-1.9.3-p551:/usr/local/rvm/gems/ruby-1.9.3-p551@global', 'HOME' => '/home/nitesh', 'USER' => 'nitesh'})
	command "passenger start -a 127.0.0.1 -p 3000 -d"
end

service "apache2" do
	action [:enable, :restart]
end