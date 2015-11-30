#
# Cookbook Name:: php
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute "apt-get update"

%w(curl wget git-core zlib1g-dev libssl-dev libxml2-dev libxslt1-dev).each do |pkg|
	package pkg
end

%w(php5 php5-mcrypt php5-memcache php5-mysql php5-sqlite php5-json php5-curl php5-pgsql libapache2-mod-php5).each do |pkg|
	package pkg
end

####git commands
git node[:project][:home] do
	repository node[:project][:repository]
	revision "master"
	timeout 4400
	action :sync
end

cookbook_file "/var/www/drupal/sites/default/settings.php" do
	source "settings.php"
	user "nitesh"
	group "nitesh"
end

package "apache2"

template "/etc/apache2/sites-available/local-drupal.conf" do
	source "local-drupal.erb"
	user "root"
	group "root"
end

directory node[:project][:home] do
	user "nitesh"
	group "nitesh"
	recursive true
end

execute "enable drupal site" do
	command "cd /etc/apache2/sites-available && sudo a2ensite local-drupal.conf"
	cwd node[:project][:home]
end

service "apache2" do
	action [:enable, :restart]
end