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
