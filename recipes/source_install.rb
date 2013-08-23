# Cookbook Name:: ktc-compute
# Recipe:: source_install
#

include_recipe "python"

user node["openstack"]["compute"]["user"] do
  home "/var/lib/nova"
  shell "/bin/sh"
  supports :manage_home => true
end

%w{ libxml2-dev libxslt-dev }.each do |pkg|
  package pkg do
    action :install
  end
end

git "#{Chef::Config[:file_cache_path]}/nova" do
  repository "https://github.com/kt-cloudware/nova.git"
  reference "develop"
  action :sync
  notifies :install, "python_pip[nova-requires]", :immediately
  notifies :run, "bash[install_nova]", :immediately
end

python_pip "nova-requires" do
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
  owner "#{node["openstack"]["compute"]["user"]}"
  group "adm"
  mode 00750
  action :create
end
