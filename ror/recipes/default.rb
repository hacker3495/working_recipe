#
# Cookbook Name:: ror
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

####basic packages

execute "apt-get update"

%w(curl wget git-core zlib1g-dev libssl-dev libxml2-dev libxslt1-dev).each do |pkg|
  package pkg
end

execute "gpg_key" do
	command "sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"
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