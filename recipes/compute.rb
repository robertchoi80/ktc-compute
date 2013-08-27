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


#
# this is a hack to work around metadata service getting installed
#
unless node.recipes.include? "ktc-compute::compute-api"
  # this should "fake out" any calls to include_recipe
  # seee  https://github.com/opscode/chef/blob/master/lib/chef/run_context.rb#L140-L153
  run_context.loaded_recipes << "openstack-compute::api-metadata"
  package "nova-api-metadata" do
    action :remove
  end
end


set_rabbit_servers "compute"
set_memcached_servers
set_database_servers "compute"
set_service_endpoint "identity-api"
set_service_endpoint "identity-admin"
set_service_endpoint "image-registry"
set_service_endpoint "image-api"
set_service_endpoint "network-api"
set_service_endpoint "compute-api"
set_service_endpoint "compute-ec2-api"
set_service_endpoint "compute-ec2-admin"

include_recipe "ktc-utils"
include_recipe "ktc-compute::nova-common"
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
