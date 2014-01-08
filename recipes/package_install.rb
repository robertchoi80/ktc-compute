# Cookbook Name:: ktc-compute
# Recipe:: package_install
#

include_recipe "sudo"
include_recipe "python"

user node["openstack"]["compute"]["user"] do
  home "/var/lib/nova"
  shell "/bin/sh"
  system  true
  supports :manage_home => true
end

sudo "nova_sudoers" do
  user     "nova"
  host     "ALL"
  runas    "root"
  nopasswd true
  commands ["/usr/local/bin/nova-rootwrap"]
end

directory "/var/log/nova" do
  owner node["openstack"]["compute"]["user"]
  group "adm"
  mode 00750
  action :create
end

directory "/var/lib/nova/instances" do
  owner node["openstack"]["compute"]["user"]
  group node["openstack"]["compute"]["group"]
  mode 00755
  action :create
end

node["openstack"]["compute"]["platform"]["requires_packages"].each do |pkg|
  package pkg do
    action :install
  end
end

package "nova" do
  action :install
  version node["nova_version"] unless node["nova_version"].nil?
end
