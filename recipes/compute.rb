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
set_service_endpoint "identity-api"
set_service_endpoint "identity-admin"
set_service_endpoint "image-registry"
set_service_endpoint "image-api"
set_service_endpoint "network-api"
set_service_endpoint "compute-metadata-api"
set_service_endpoint "compute-api"
set_service_endpoint "compute-ec2-api"
set_service_endpoint "compute-ec2-admin"
set_service_endpoint "compute-novnc"
set_service_endpoint "compute-xvpvnc"

include_recipe "ktc-utils"
include_recipe "ktc-network::agents"
include_recipe "ktc-compute::nova-common"

cookbook_file "/etc/init/nova-compute.conf" do
  source "etc/init/nova-compute.conf"
  action :create
end

include_recipe "openstack-compute::compute"

chef_gem "chef-rewind"
require 'chef/rewind'

# Prevent compute recipe from installing nova-compute-kvm or nova-compute-qemu package
virt_type = node["openstack"]["compute"]["libvirt"]["virt_type"]
if %w{ kvm qemu }.include? virt_type
  rewind :package => "nova-compute-#{virt_type}" do
    action :nothing
  end
end

rewind :service => "nova-compute" do
  provider Chef::Provider::Service::Upstart
end

# Add cgroup_device_acl option to /etc/libvirt/qemu.conf
cookbook_file "/etc/libvirt/qemu.conf" do
  source "qemu.conf.erb"
  owner "nova"
  group "nova"
  mode "0600"
  notifies :restart, resources(:service => "libvirt-bin"), :immediately
end
