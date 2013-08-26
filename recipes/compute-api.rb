# Cookbook Name:: ktc-compute
# Recipe:: compute-api
#

class Chef::Recipe
  include KTCUtils
end

d0 = get_openstack_service_template(get_interface_address("management"), "8775")
register_member("compute-metadata-api", d0)

d1 = get_openstack_service_template(get_interface_address("management"), "8774")
register_member("compute-api", d1)

d2 = get_openstack_service_template(get_interface_address("management"), "8773")
register_member("compute-ec2-api", d2)

d3 = get_openstack_service_template(get_interface_address("management"), "8773")
register_member("compute-ec2-admin", d3)

d4 = get_openstack_service_template(get_interface_address("management"), "6081")
register_member("compute-xvpvnc", d4)

d5 = get_openstack_service_template(get_interface_address("management"), "6080")
register_member("compute-novnc", d5)

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
set_service_endpoint "compute-xvpvnc"
set_service_endpoint "compute-novnc"

iface = node["interface_mapping"]["management"]
node.default["openstack"]["compute"]["libvirt"]["bind_interface"] = iface
node.default["openstack"]["compute"]["xvpvnc_proxy"]["bind_interface"] = iface
node.default["openstack"]["compute"]["novnc_proxy"]["bind_interface"] = iface

include_recipe "openstack-common"
include_recipe "openstack-common::logging"
include_recipe "openstack-object-storage::memcached"
include_recipe "ktc-compute::nova-common"

service_list = %w{ scheduler conductor api-ec2 api-os-compute api-metadata cert consoleauth novncproxy }
service_list.each do |service|
  cookbook_file "/etc/init/nova-#{service}.conf" do
    source "etc/init/nova-#{service}.conf"
    action :create
  end
end

include_recipe "ark"
ark "novnc" do
  path "/usr/share"
  url node["openstack"]["compute"]["platform"]["novnc"]["url"]
  action :put
end

include_recipe "openstack-compute::nova-setup"
include_recipe "openstack-compute::scheduler"
include_recipe "openstack-compute::conductor"
include_recipe "openstack-compute::api-ec2"
include_recipe "openstack-compute::api-os-compute"
include_recipe "openstack-compute::api-metadata"
include_recipe "openstack-compute::nova-cert"
include_recipe "openstack-compute::vncproxy"

chef_gem "chef-rewind"
require 'chef/rewind'

service_list.each do |service|
  rewind :service => "nova-#{service}" do
    provider Chef::Provider::Service::Upstart
  end
end

include_recipe "openstack-compute::identity_registration"
