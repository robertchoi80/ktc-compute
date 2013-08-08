#
# Cookbook Name:: ktc-compute
# Recipe:: compute
#

#class ::Chef::Recipe
#  include ::Openstack
#end

class Chef::Recipe
  include KTCUtils
end

set_rabbit_servers "compute"
set_memcached_servers
set_database_servers "compute"

chef_gem "chef-rewind"
require 'chef/rewind'

include_recipe "ktc-utils"
include_recipe "openstack-compute::compute"
include_recipe "openstack-compute::conductor"
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
