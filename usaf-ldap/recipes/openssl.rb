execute "apt-get update" do
  command "apt-get update -y"
end

#package "git"

# %w{openssh-server openssh-client}.each do |pkg|
# package pkg do
#   action :purge
# end
#end

# git "/opt/openssh_6.2" do
#   repository "https://github.com/lokesh-webonise/openssh6.2"
#   revision "master"
#   action :checkout
# end


package "libck-connector0"

script "sudoers configuration" do
  interpreter "bash"
  user "root"
  code <<-EOH
        echo "session required        pam_mkhomedir.so" >> /etc/pam.d/common-session
        echo "%wheel ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers 
  EOH
end

service "ssh" do
  supports :restart => true, :reload => true, :start => true
  action :start
end

cookbook_file "/etc/ssh/sshd_config" do
  source "sshd_config.conf"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, "service[ssh]"
end

execute "ssh update-rc" do
command "sudo update-rc.d ssh defaults"
end

######################################################################

package "libnss-ldap"
package "libnss-ldapd"

service "nslcd" do
  supports :restart => true, :reload => true, :start => true
  action :start
end

service "nscd" do
  supports :restart => true, :reload => true, :start => true
  action :start
end

cookbook_file "/etc/ldap.conf" do
  source "ldap.conf"
  mode 0644
  owner "root"
  group "root"
end

cookbook_file "/etc/ldap.secret" do
  source "ldap.secret"
  mode 0644
  owner "root"
  group "root"
end

cookbook_file "/etc/nslcd.conf" do
  source "nslcd.conf"
  mode 0644
  owner "root"
  group "root"
end

cookbook_file "/usr/local/bin/ldap_keys.sh" do
  source "ldap_keys.sh"
  mode 0755
  owner "root"
  group "root"
end

cookbook_file "/etc/nsswitch.conf" do
  source "nsswitch.conf"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, "service[nslcd]"
  notifies :restart, "service[nscd]"
end
