include_recipe "jenkins"
include_recipe "ant"

include_recipe "php"

execute "enable pear autodiscovery" do
  command "pear config-set auto_discover 1"
  action :run
  not_if "pear config-get auto_discover 2> /dev/null | grep '1'"
end

execute "install phpqatools" do
  command "pear install pear install pear.phpqatools.org/phpqatools > /dev/null 2>&1 &"
  action :run
end

execute "install phpDox" do
  command "pear install pear.netpirates.net/phpDox > /dev/null 2>&1 &"
  action :run
end

#workaround for https://github.com/fnichol/chef-jenkins/issues/9
directory "#{node['jenkins']['server']['home']}/updates/" do
  owner node['jenkins']['server']['user']
  group node['jenkins']['server']['user']
  action :create
end

execute "update jenkins update center" do
  command "wget http://updates.jenkins-ci.org/update-center.json -qO- | sed '1d;$d'  > #{node['jenkins']['server']['home']}/updates/default.json"
  user node['jenkins']['server']['user']
  group node['jenkins']['server']['user']
  creates "#{node['jenkins']['server']['home']}/updates/default.json"
end

jenkins_cli "install-plugin checkstyle cloverphp dry htmlpublisher jdepend plot pmd violations xunit git"

directory "#{node['jenkins']['server']['home']}/jobs/php-template/" do
  owner node['jenkins']['server']['user']
  group node['jenkins']['server']['user']
  action :create
end

template "#{node['jenkins']['server']['home']}/jobs/php-template/config.xml" do
  source "config.xml.erb"
  owner node['jenkins']['server']['user']
  group node['jenkins']['server']['user']
  mode "0644"
end

jenkins_cli "safe-restart"
