#
# Cookbook Name:: ktc-compute
# Recipe:: compute
#
class ::Chef::Recipe
  include ::Openstack
end

class Chef::Recipe
  include KTCUtils
end

# search for node/s with rabbit recipe
set_rabbit_servers "compute"

# search for node with memcached recipe
memcached_servers = search_for "infra-caching"
if memcached_servers.length == 1
  node.default["memcached"]["listen"] = get_interface_address("management", memcached_servers.first)
elsif memcached_servers.length > 1
  node.default["memcached"]["listen"] = get_interface_address("management", memcached_servers.first)
  puts "#### TODO: deal with multiple memcached servers, just setting first for now"
end

# search for node with mysql recipe
mysql_servers = search_for "os-ops-database"
if mysql_servers.length == 1
  node.default["openstack"]["db"]["compute"]["host"] = get_interface_address("management", mysql_servers.first)
elsif
  node.default["openstack"]["db"]["compute"]["host"] = get_interface_address("management", mysql_servers.first)
  puts "#### TODO: deal with multiple mysql servers, just setting first for now"
end


chef_gem "chef-rewind"
require 'chef/rewind'

include_recipe "ktc-utils"
include_recipe "openstack-compute::compute"
# Add cgroup_device_acl option to /etc/libvirt/qemu.conf
cookbook_file "/etc/libvirt/qemu.conf" do
  source "qemu.conf.erb"
  owner "nova"
  group "nova"
  mode "0600"
  notifies :restart, resources(:service => "libvirt-bin"), :immediately
end

# Rewind nova-compute.conf template to use the "lb" config source
if node["quantum"]["plugin"] == "lb"
  rewind :template => "/etc/nova/nova-compute.conf" do
    source "folsom/nova-compute.conf.erb"
    cookbook_name "ktc-compute"
  end
end

# apply fixes for nova-compute
%w{ 2012.2.1+stable-20121212-a99a802e-0ubuntu1.4~cloud0 2012.2.3-0ubuntu2~cloud0 }.each do |version|
  if ::Chef::Recipe::Patch.check_package_version("nova-compute",version,node)
    template "/usr/share/pyshared/nova/network/quantumv2/api.py" do
      source "ktc-patches/api.py.#{version}"
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, resources(:service => "nova-compute"), :immediately
    end
  end
  if ::Chef::Recipe::Patch.check_package_version("nova-compute",version,node)
    template "/usr/share/pyshared/nova/compute/manager.py" do
      source "ktc-patches/manager.py.#{version}"
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, resources(:service => "nova-compute"), :immediately
    end
  end
end
