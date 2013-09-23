# Cookbook Name:: ktc-compute
# Recipe:: source_install
#

include_recipe "sudo"
include_recipe "python"

user node["openstack"]["compute"]["user"] do
  home "/var/lib/nova"
  shell "/bin/sh"
  supports :manage_home => true
end

sudo "nova_sudoers" do
  user     "nova"
  host     "ALL"
  runas    "root"
  nopasswd true
  commands ["/usr/local/bin/nova-rootwrap"]
end

# Install pip-requires using ubuntu packages first, then install the rest with pip.
# Prefer installing ubuntu pakcages to compiling python modules on nodes.
node["openstack"]["compute"]["platform"]["pip_requires_packages"].each do |pkg|
  package pkg do
    action :install
  end
end

git "#{Chef::Config[:file_cache_path]}/nova" do
  repository node["openstack"]["compute"]["platform"]["nova"]["git_repo"]
  reference node["openstack"]["compute"]["platform"]["nova"]["git_ref"]
  action :sync
  notifies :install, "python_pip[nova-pip-requires]", :immediately
  notifies :run, "bash[install_nova]", :immediately
end

python_pip "nova-pip-requires" do
  package_name "#{Chef::Config[:file_cache_path]}/nova/tools/pip-requires"
  options "-r"
  action :nothing
end

bash "install_nova" do
  cwd "#{Chef::Config[:file_cache_path]}/nova"
  code <<-EOF
    python ./setup.py install
  EOF
  action :nothing
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
